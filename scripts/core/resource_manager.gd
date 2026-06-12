extends Node

class_name ResourceManager

var wood = 0
var stone = 0
var iron = 0
var food = 0

var max_wood = 1000
var max_stone = 1000
var max_iron = 500
var max_food = 500

var _logger: Logger
var _event_bus: EventBus

func _ready():
	_logger = GameManager.instance.logger
	_event_bus = GameManager.instance.event_bus

func initialize():
	wood = 10
	stone = 5
	iron = 0
	food = 20
	_logger.info("ResourceManager initialized", "ResourceManager")

func add_resource(resource_type: String, amount: int) -> int:
	var actual_amount = 0
	
	match resource_type:
		"wood":
			actual_amount = min(amount, max_wood - wood)
			wood += actual_amount
		"stone":
			actual_amount = min(amount, max_stone - stone)
			stone += actual_amount
		"iron":
			actual_amount = min(amount, max_iron - iron)
			iron += actual_amount
		"food":
			actual_amount = min(amount, max_food - food)
			food += actual_amount
	
	if actual_amount > 0:
		_event_bus.emit_resource_collected(resource_type, actual_amount)
	
	return actual_amount

func remove_resource(resource_type: String, amount: int) -> bool:
	match resource_type:
		"wood":
			if wood >= amount:
				wood -= amount
				return true
		"stone":
			if stone >= amount:
				stone -= amount
				return true
		"iron":
			if iron >= amount:
				iron -= amount
				return true
		"food":
			if food >= amount:
				food -= amount
				return true
	
	return false

func has_resources(resources: Dictionary) -> bool:
	if resources.has("wood") and wood < resources["wood"]:
		return false
	if resources.has("stone") and stone < resources["stone"]:
		return false
	if resources.has("iron") and iron < resources["iron"]:
		return false
	if resources.has("food") and food < resources["food"]:
		return false
	
	return true

func consume_resources(resources: Dictionary) -> bool:
	if not has_resources(resources):
		return false
	
	if resources.has("wood"):
		wood -= resources["wood"]
	if resources.has("stone"):
		stone -= resources["stone"]
	if resources.has("iron"):
		iron -= resources["iron"]
	if resources.has("food"):
		food -= resources["food"]
	
	return true

func get_total_resources() -> int:
	return wood + stone + iron + food

func get_storage_percentage() -> float:
	var total = get_total_resources()
	var max_total = max_wood + max_stone + max_iron + max_food
	return float(total) / float(max_total)

func to_dict() -> Dictionary:
	return {
		"wood": wood,
		"stone": stone,
		"iron": iron,
		"food": food,
		"max_wood": max_wood,
		"max_stone": max_stone,
		"max_iron": max_iron,
		"max_food": max_food
	}

func from_dict(data: Dictionary):
	wood = data.get("wood", 10)
	stone = data.get("stone", 5)
	iron = data.get("iron", 0)
	food = data.get("food", 20)
	max_wood = data.get("max_wood", 1000)
	max_stone = data.get("max_stone", 1000)
	max_iron = data.get("max_iron", 500)
	max_food = data.get("max_food", 500)

func update(_delta: float):
	pass