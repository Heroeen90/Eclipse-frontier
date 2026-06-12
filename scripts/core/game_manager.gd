extends Node

class_name GameManager

# Singleton instance
static var instance: GameManager

# Game state
var is_paused = false
var current_level = 1
var total_playtime = 0.0
var session_start_time = 0

# Managers
var player_manager: PlayerStats
var inventory_manager: InventoryManager
var save_system: SaveSystem
var quest_manager: QuestManager
var world_manager: WorldManager
var resource_manager: ResourceManager
var event_bus: EventBus
var logger: Logger

func _ready():
	if instance == null:
		instance = self
	else:
		queue_free()
		return
	
	set_multiplayer_authority(1)
	get_tree().root.add_child(self)
	
	# Initialize all managers
	_initialize_managers()
	_load_game()
	_connect_signals()
	
	logger.info("GameManager initialized successfully", "GameManager")
	
	# Set up game loop
	Engine.target_fps = Constants.TARGET_FPS
	session_start_time = Time.get_ticks_msec()

func _initialize_managers():
	# Create or find existing managers
	event_bus = EventBus.new()
	add_child(event_bus)
	
	logger = Logger.new()
	add_child(logger)
	
	player_manager = PlayerStats.new()
	add_child(player_manager)
	
	inventory_manager = InventoryManager.new()
	add_child(inventory_manager)
	
	save_system = SaveSystem.new()
	add_child(save_system)
	
	quest_manager = QuestManager.new()
	add_child(quest_manager)
	
	resource_manager = ResourceManager.new()
	add_child(resource_manager)

func _connect_signals():
	event_bus.game_paused.connect(_on_game_paused)
	event_bus.game_resumed.connect(_on_game_resumed)
	event_bus.game_over.connect(_on_game_over)
	event_bus.game_saved.connect(_on_game_saved)

func _load_game():
	if save_system.has_save_file():
		var save_data = save_system.load_game()
		if save_data:
			current_level = save_data.get("level", 1)
			total_playtime = save_data.get("playtime", 0.0)
			logger.info("Game loaded successfully", "GameManager")
		else:
			_start_new_game()
	else:
		_start_new_game()

func _start_new_game():
	player_manager.initialize()
	inventory_manager.clear()
	quest_manager.reset()
	current_level = 1
	total_playtime = 0.0
	logger.info("New game started", "GameManager")

func _process(delta):
	total_playtime += delta
	
	if not is_paused:
		_update_game(delta)

func _update_game(delta):
	if player_manager:
		player_manager.update(delta)
	
	if quest_manager:
		quest_manager.update(delta)
	
	if resource_manager:
		resource_manager.update(delta)

func pause_game():
	is_paused = true
	get_tree().paused = true
	event_bus.emit_game_paused()
	logger.debug("Game paused", "GameManager")

func resume_game():
	is_paused = false
	get_tree().paused = false
	event_bus.emit_game_resumed()
	logger.debug("Game resumed", "GameManager")

func toggle_pause():
	if is_paused:
		resume_game()
	else:
		pause_game()

func save_game(slot: int = 0) -> bool:
	var save_data = {
		"version": Constants.GAME_VERSION,
		"level": current_level,
		"playtime": total_playtime,
		"timestamp": Time.get_datetime_string_from_system(),
		"player": player_manager.to_dict(),
		"inventory": inventory_manager.to_dict(),
		"quests": quest_manager.to_dict(),
		"resources": resource_manager.to_dict()
	}
	
	var success = save_system.save_game(save_data, slot)
	if success:
		event_bus.emit(EventBus.game_saved, slot)
		logger.info("Game saved to slot %d" % slot, "GameManager")
	else:
		logger.error("Failed to save game to slot %d" % slot, "GameManager")
	
	return success

func load_game(slot: int = 0) -> bool:
	var save_data = save_system.load_game(slot)
	if save_data:
		current_level = save_data.get("level", 1)
		total_playtime = save_data.get("playtime", 0.0)
		player_manager.from_dict(save_data.get("player", {}))
		inventory_manager.from_dict(save_data.get("inventory", {}))
		quest_manager.from_dict(save_data.get("quests", {}))
		event_bus.emit(EventBus.game_loaded, slot)
		logger.info("Game loaded from slot %d" % slot, "GameManager")
		return true
	
	logger.error("Failed to load game from slot %d" % slot, "GameManager")
	return false

func end_game(victory: bool = false):
	if victory:
		event_bus.game_won.emit()
		logger.info("Game won!", "GameManager")
	else:
		event_bus.game_over.emit()
		logger.info("Game over", "GameManager")
	
	save_game()
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()

func _on_game_paused():
	get_tree().paused = true

func _on_game_resumed():
	get_tree().paused = false

func _on_game_over():
	logger.warning("Game ended", "GameManager")
	save_game()

func _on_game_saved(_slot: int):
	logger.info("Save confirmed", "GameManager")

func get_playtime_string() -> String:
	var hours = int(total_playtime) / 3600
	var minutes = (int(total_playtime) % 3600) / 60
	var seconds = int(total_playtime) % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

func quit_game():
	save_game()
	logger.info("Game quit", "GameManager")
	get_tree().quit()