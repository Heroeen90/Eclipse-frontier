extends Control

class_name BuildingMenu

@onready var building_list = $VBoxContainer/BuildingList
@onready var building_info_panel = $VBoxContainer/BuildingInfoPanel
@onready var close_button = $VBoxContainer/CloseButton

var buildings_data: Dictionary = {}
var builder: Builder
var selected_building: String = ""

var _logger: Logger
var _event_bus: EventBus

func _ready():
	_logger = GameManager.instance.logger
	_event_bus = GameManager.instance.event_bus
	builder = GameManager.instance.get_tree().root.get_node("World/Builder")
	
	_load_buildings_data()
	_setup_ui()
	_connect_signals()
	
	_logger.info("BuildingMenu initialized", "BuildingMenu")

func _load_buildings_data():
	var file = FileAccess.open("res://data/buildings_data.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var content = file.get_as_text()
		if json.parse(content) == OK:
			buildings_data = json.get_data()

func _setup_ui():
	for building_type in buildings_data.keys():
		var button = Button.new()
		button.text = building_type
		button.custom_minimum_size = Vector2(150, 40)
		button.pressed.connect(_on_building_selected.bindv([building_type]))
		building_list.add_child(button)
	
	close_button.pressed.connect(_on_close_pressed)

func _connect_signals():
	_event_bus.building_constructed.connect(_on_building_built)

func _on_building_selected(building_type: String):
	selected_building = building_type
	var building_data = buildings_data.get(building_type, {})
	
	var info_text = "%s\n" % building_type.to_upper()
	info_text += "Cost:\n"
	
	var cost = building_data.get("cost", {})
	for resource_type in cost:
		info_text += "%s: %d\n" % [resource_type, cost[resource_type]]
	
	building_info_panel.text = info_text
	
	_logger.debug("Building selected: %s" % building_type, "BuildingMenu")
	
	# Start preview
	if builder:
		builder.start_building_preview(building_type)

func _on_close_pressed():
	if builder:
		builder.stop_building_preview()
	visible = false
	_logger.debug("BuildingMenu closed", "BuildingMenu")

func _on_building_built(building_type: String, _position: Vector2):
	_event_bus.emit_ui_notification("Built %s successfully!" % building_type, "success")