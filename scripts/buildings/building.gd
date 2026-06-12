extends Node2D

class_name Building

enum BuildingType { HOUSE, STORAGE, MINE, FARM }

var building_type: BuildingType = BuildingType.HOUSE
var building_name: String = "Building"
var position_in_world: Vector2 = Vector2.ZERO
var health: float = 100.0
var max_health: float = 100.0
var level: int = 1
var max_level: int = 5

var construction_time: float = 5.0
var is_under_construction: bool = true
var construction_progress: float = 0.0

var upgrade_cost: Dictionary = {}
var production_rate: float = 1.0
var storage_capacity: float = 100.0

var _logger: Logger
var _event_bus: EventBus
var _sprite: Sprite2D
var _collision_shape: CollisionShape2D

func _ready():
	_logger = GameManager.instance.logger
	_event_bus = GameManager.instance.event_bus
	
	_setup_visuals()
	_connect_signals()

func _setup_visuals():
	_sprite = Sprite2D.new()
	add_child(_sprite)
	
	match building_type:
		BuildingType.HOUSE:
			_sprite.modulate = Color.LIGHT_GRAY
		BuildingType.STORAGE:
			_sprite.modulate = Color.BROWN
		BuildingType.MINE:
			_sprite.modulate = Color.DARK_GRAY
		BuildingType.FARM:
			_sprite.modulate = Color.GREEN

func _connect_signals():
	_event_bus.damage_taken.connect(_on_damage_taken)

func initialize(type: BuildingType, name: String, pos: Vector2):
	building_type = type
	building_name = name
	position_in_world = pos
	global_position = pos

func _physics_process(delta):
	if is_under_construction:
		_update_construction(delta)

func _update_construction(delta):
	construction_progress += delta / construction_time
	if construction_progress >= 1.0:
		complete_construction()

func complete_construction():
	is_under_construction = false
	construction_progress = 1.0
	_event_bus.emit_building_constructed(building_name, position_in_world)
	_logger.info("Construction completed: %s" % building_name, "Building")

func take_damage(damage: float):
	health = max(0.0, health - damage)
	_event_bus.emit(EventBus.building_damaged, building_name, damage)
	
	if health <= 0:
		destroy()

func repair(amount: float):
	health = min(max_health, health + amount)

func upgrade() -> bool:
	if level >= max_level:
		_logger.warning("Building already at max level", "Building")
		return false
	
	if not GameManager.instance.resource_manager.has_resources(upgrade_cost):
		_logger.warning("Insufficient resources to upgrade", "Building")
		return false
	
	GameManager.instance.resource_manager.consume_resources(upgrade_cost)
	level += 1
	max_health *= 1.2
	health = max_health
	production_rate *= 1.15
	
	_event_bus.emit(EventBus.building_upgraded, building_name)
	_logger.info("Building upgraded to level %d: %s" % [level, building_name], "Building")
	
	return true

func produce() -> Dictionary:
	# Override in subclasses
	return {}

func destroy():
	_event_bus.emit(EventBus.building_destroyed, building_name, position_in_world)
	_logger.info("Building destroyed: %s" % building_name, "Building")
	queue_free()

func get_health_percentage() -> float:
	return health / max_health

func to_dict() -> Dictionary:
	return {
		"building_type": building_type,
		"building_name": building_name,
		"position": {"x": position_in_world.x, "y": position_in_world.y},
		"health": health,
		"level": level,
		"is_under_construction": is_under_construction,
		"construction_progress": construction_progress
	}

func from_dict(data: Dictionary):
	building_type = data.get("building_type", BuildingType.HOUSE)
	building_name = data.get("building_name", "Building")
	health = data.get("health", max_health)
	level = data.get("level", 1)
	is_under_construction = data.get("is_under_construction", false)
	construction_progress = data.get("construction_progress", 0.0)