extends Control

class_name InventoryUI

@onready var slot_container = $VBoxContainer/SlotContainer
@onready var item_info_panel = $VBoxContainer/ItemInfoPanel
@onready var weight_label = $VBoxContainer/WeightLabel

var inventory_manager: InventoryManager
var slot_buttons: Array[Button] = []
var selected_slot = -1

var _logger: Logger
var _event_bus: EventBus

func _ready():
	_logger = GameManager.instance.logger
	_event_bus = GameManager.instance.event_bus
	inventory_manager = GameManager.instance.inventory_manager
	
	_setup_ui()
	_connect_signals()
	_logger.info("InventoryUI initialized", "InventoryUI")

func _setup_ui():
	for i in range(Constants.MAX_INVENTORY_SLOTS):
		var button = Button.new()
		button.custom_minimum_size = Vector2(60, 60)
		button.text = str(i + 1)
		button.pressed.connect(_on_slot_pressed.bindv([i]))
		slot_container.add_child(button)
		slot_buttons.append(button)

func _connect_signals():
	_event_bus.inventory_item_added.connect(_on_inventory_changed)
	_event_bus.inventory_item_removed.connect(_on_inventory_changed)

func _on_slot_pressed(slot_index: int):
	selected_slot = slot_index
	_update_item_info()

func _on_inventory_changed(_item: InventoryItem, _amount: int):
	_update_display()

func _update_display():
	for i in range(slot_buttons.size()):
		var item = inventory_manager.inventory.get_item_at_slot(i)
		if item:
			slot_buttons[i].text = "%s\n%d" % [item.item_name[0], item.quantity]
		else:
			slot_buttons[i].text = str(i + 1)
	
	_update_weight_label()

func _update_item_info():
	if selected_slot < 0:
		return
	
	var item = inventory_manager.inventory.get_item_at_slot(selected_slot)
	if item:
		item_info_panel.text = "%s\n%s\nQuantity: %d" % [
			item.item_name,
			item.item_description,
			item.quantity
		]
	else:
		item_info_panel.text = "Empty slot"

func _update_weight_label():
	var weight_percent = inventory_manager.inventory.get_weight_percentage()
	weight_label.text = "Weight: %.1f/%.1f kg (%.0f%%)" % [
		inventory_manager.inventory.current_weight,
		inventory_manager.inventory.max_weight,
		weight_percent * 100
	]

func show_inventory():
	visible = true
	_update_display()

func hide_inventory():
	visible = false