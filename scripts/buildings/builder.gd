extends Node

class_name Builder

var building_manager: BuildingManager
var preview_building: Node2D
var is_previewing: bool = false
var selected_building_type: String = "house"

var _logger: Logger
var _event_bus: EventBus
var _player_position: Vector2 = Vector2.ZERO

func _ready():
	_logger = GameManager.instance.logger
	_event_bus = GameManager.instance.event_bus
	building_manager = GameManager.instance.building_manager

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if is_previewing:
				_attempt_build()

func _process(_delta):
	if is_previewing:
		_update_preview()

func start_building_preview(building_type: String):
	selected_building_type = building_type
	is_previewing = true
	_create_preview()
	_logger.debug("Building preview started: %s" % building_type, "Builder")

func stop_building_preview():
	is_previewing = false
	if preview_building:
		preview_building.queue_free()
	_logger.debug("Building preview stopped", "Builder")

func _create_preview():
	preview_building = Node2D.new()
	var sprite = Sprite2D.new()
	sprite.modulate = Color.CYAN
	sprite.modulate.a = 0.5
	preview_building.add_child(sprite)

func _update_preview():
	if preview_building:
		preview_building.global_position = get_global_mouse_position()

func _attempt_build():
	var build_position = get_global_mouse_position()
	
	if building_manager.can_build(selected_building_type, build_position):
		if building_manager.build_building(selected_building_type, build_position):
			_logger.info("Building placed: %s at %s" % [selected_building_type, build_position], "Builder")
	else:
		_logger.warning("Cannot build at this location", "Builder")