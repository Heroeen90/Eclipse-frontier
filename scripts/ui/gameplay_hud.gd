extends CanvasLayer

class_name GameplayHUD

@onready var health_bar = $Control/HealthBar
@onready var health_label = $Control/HealthLabel
@onready var energy_bar = $Control/EnergyBar
@onready var energy_label = $Control/EnergyLabel
@onready var level_label = $Control/LevelLabel
@onready var exp_bar = $Control/ExperienceBar
@onready var resource_panel = $Control/ResourcePanel
@onready var minimap = $Control/Minimap
@onready var fps_label = $Control/FPSLabel
@onready var pause_button = $Control/PauseButton

var player_stats: PlayerStats
var resource_manager: ResourceManager
var _logger: Logger
var _event_bus: EventBus
var _is_visible = true

func _ready():
	_logger = GameManager.instance.logger
	_event_bus = GameManager.instance.event_bus
	player_stats = GameManager.instance.player_manager
	resource_manager = GameManager.instance.resource_manager
	
	_setup_ui()
	_connect_signals()
	
	_logger.info("GameplayHUD initialized", "GameplayHUD")

func _setup_ui():
	# Setup health bar
	health_bar.max_value = player_stats.max_health
	health_bar.value = player_stats.current_health
	
	# Setup energy bar
	energy_bar.max_value = player_stats.max_energy
	energy_bar.value = player_stats.current_energy
	
	# Setup experience bar
	exp_bar.max_value = player_stats.experience_for_next_level
	exp_bar.value = player_stats.current_experience

func _connect_signals():
	_event_bus.player_health_changed.connect(_on_health_changed)
	_event_bus.player_energy_changed.connect(_on_energy_changed)
	_event_bus.player_level_up.connect(_on_level_up)
	_event_bus.player_experience_gained.connect(_on_experience_gained)
	_event_bus.resource_collected.connect(_on_resource_collected)
	pause_button.pressed.connect(_on_pause_pressed)

func _physics_process(_delta):
	_update_labels()
	_update_fps_counter()
	_update_resource_panel()

func _on_health_changed(health: float):
	health_bar.value = health
	_logger.debug("HUD health updated: %.1f" % health, "GameplayHUD")

func _on_energy_changed(energy: float):
	energy_bar.value = energy

func _on_level_up(level: int):
	level_label.text = "Level: %d" % level

func _on_experience_gained(amount: int):
	exp_bar.value = player_stats.current_experience

func _on_resource_collected(resource_type: String, amount: int):
	_event_bus.emit_ui_notification("+%d %s" % [amount, resource_type], "info")

func _on_pause_pressed():
	GameManager.instance.toggle_pause()

func _update_labels():
	health_label.text = "HP: %.0f/%.0f" % [player_stats.current_health, player_stats.max_health]
	energy_label.text = "Energy: %.0f/%.0f" % [player_stats.current_energy, player_stats.max_energy]
	level_label.text = "Level: %d" % player_stats.current_level

func _update_fps_counter():
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _update_resource_panel():
	var text = "Resources:\nWood: %d\nStone: %d\nIron: %d\nFood: %d" % [
		resource_manager.wood,
		resource_manager.stone,
		resource_manager.iron,
		resource_manager.food
	]
	resource_panel.text = text

func toggle_visibility():
	_is_visible = !_is_visible
	visible = _is_visible

func show_notification(message: String, type: String = "info"):
	_event_bus.emit_ui_notification(message, type)