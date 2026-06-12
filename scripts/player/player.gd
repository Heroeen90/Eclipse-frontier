extends Node

class_name Player

var player_stats: PlayerStats
var player_controller: PlayerController
var player_movement: PlayerMovement
var player_animation: PlayerAnimation

var _logger: Logger
var _event_bus: EventBus

func _ready():
	_logger = GameManager.instance.logger
	_event_bus = GameManager.instance.event_bus
	
	player_stats = GameManager.instance.player_manager
	
	_setup_components()
	_connect_signals()
	_logger.info("Player system initialized", "Player")

func _setup_components():
	var scene = load("res://scenes/player/player.tscn")
	if scene:
		var player_scene = scene.instantiate()
		add_child(player_scene)
		
		player_controller = player_scene.get_node_or_null("PlayerController")
		player_movement = player_scene.get_node_or_null("PlayerMovement")
		player_animation = player_scene.get_node_or_null("PlayerAnimation")

func _connect_signals():
	_event_bus.player_died.connect(_on_player_died)
	_event_bus.player_level_up.connect(_on_player_level_up)
	_event_bus.player_health_changed.connect(_on_health_changed)

func _on_player_died():
	_logger.warning("Player died!", "Player")

func _on_player_level_up(level: int):
	_event_bus.emit_ui_notification("Level Up! You are now level %d" % level, "success")
	_logger.info("Player reached level %d" % level, "Player")

func _on_health_changed(health: float):
	_logger.debug("Player health: %.1f" % health, "Player")

func take_damage(damage: float, source: String = "Unknown"):
	player_stats.take_damage(damage, source)

func heal(amount: float):
	player_stats.heal(amount)

func gain_experience(amount: int):
	player_stats.gain_experience(amount)

func set_position(new_position: Vector2):
	if player_controller:
		player_controller.global_position = new_position
	player_stats.position = new_position