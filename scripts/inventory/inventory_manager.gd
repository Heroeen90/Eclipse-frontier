extends Node

class_name InventoryManager

var inventory: Inventory

var _logger: Logger
var _event_bus: EventBus

func _ready():
	_logger = GameManager.instance.logger
	_event_bus = GameManager.instance.event_bus
	inventory = Inventory.new()
	add_child(inventory)
	_logger.info("InventoryManager initialized", "InventoryManager")

func add_item(item: InventoryItem) -> bool:
	return inventory.add_item(item)

func remove_item(item_id: String, quantity: int = 1) -> bool:
	for i in range(inventory.slots.size()):
		var item = inventory.get_item_at_slot(i)
		if item and item.item_id == item_id:
			var removed = inventory.remove_item_at_slot(i, quantity)
			if removed:
				return true
	return false

func has_item(item_id: String, quantity: int = 1) -> bool:
	return inventory.has_item(item_id, quantity)

def get_item_count(item_id: String) -> int:
	return inventory.get_item_count(item_id)

func use_item(slot_index: int) -> bool:
	var item = inventory.get_item_at_slot(slot_index)
	if not item:
		return false
	
	match item.item_type:
		InventoryItem.ItemType.CONSUMABLE:
			return _use_consumable(item, slot_index)
		InventoryItem.ItemType.TOOL:
			return _use_tool(item)
		_:
			return false

func _use_consumable(item: InventoryItem, slot_index: int) -> bool:
	var player_stats = GameManager.instance.player_manager
	
	if item.use_effect.has("heal"):
		player_stats.heal(item.use_effect["heal"])
	
	if item.use_effect.has("restore_energy"):
		player_stats.restore_energy(item.use_effect["restore_energy"])
	
	inventory.remove_item_at_slot(slot_index, 1)
	_event_bus.emit(EventBus.inventory_item_used, item)
	_logger.debug("Used item: %s" % item.item_name, "InventoryManager")
	
	return true

func _use_tool(item: InventoryItem) -> bool:
	_event_bus.emit(EventBus.inventory_item_used, item)
	_logger.debug("Used tool: %s" % item.item_name, "InventoryManager")
	return true

func clear():
	inventory.clear()

func to_dict() -> Dictionary:
	return inventory.to_dict()

func from_dict(data: Dictionary) -> void:
	inventory.from_dict(data)

func update(_delta: float):
	pass