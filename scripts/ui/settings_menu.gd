extends Control

class_name SettingsMenu

@onready var volume_slider = $VBoxContainer/VolumeSlider
@onready var difficulty_option = $VBoxContainer/DifficultyOption
@onready var graphics_option = $VBoxContainer/GraphicsOption
@onready var autosave_toggle = $VBoxContainer/AutosaveToggle
@onready var apply_button = $VBoxContainer/ApplyButton
@onready var close_button = $VBoxContainer/CloseButton

var _logger: Logger
var _event_bus: EventBus

func _ready():
	_logger = GameManager.instance.logger
	_event_bus = GameManager.instance.event_bus
	
	_setup_ui()
	_connect_signals()
	
	_logger.info("SettingsMenu initialized", "SettingsMenu")

func _setup_ui():
	# Setup volume slider
	volume_slider.min_value = 0
	volume_slider.max_value = 100
	volume_slider.value = 80
	
	# Setup difficulty option
	difficulty_option.add_item("Easy")
	difficulty_option.add_item("Normal")
	difficulty_option.add_item("Hard")
	difficulty_option.add_item("Hardcore")
	difficulty_option.select(1)  # Default: Normal
	
	# Setup graphics option
	graphics_option.add_item("Low")
	graphics_option.add_item("Medium")
	graphics_option.add_item("High")
	graphics_option.select(1)  # Default: Medium
	
	# Setup autosave toggle
	autosave_toggle.button_pressed = true

func _connect_signals():
	apply_button.pressed.connect(_on_apply_pressed)
	close_button.pressed.connect(_on_close_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)

func _on_apply_pressed():
	# Apply settings
	var volume = volume_slider.value / 100.0
	var difficulty = difficulty_option.get_item_text(difficulty_option.selected)
	var graphics = graphics_option.get_item_text(graphics_option.selected)
	var autosave = autosave_toggle.button_pressed
	
	_event_bus.emit(EventBus.sound_volume_changed, volume)
	_event_bus.emit(EventBus.graphics_quality_changed, graphics)
	_event_bus.emit(EventBus.difficulty_changed, difficulty)
	
	_logger.info("Settings applied: Volume=%.0f, Difficulty=%s, Graphics=%s" % [volume_slider.value, difficulty, graphics], "SettingsMenu")
	_event_bus.emit_ui_notification("Settings applied successfully", "success")

func _on_close_pressed():
	visible = false
	_logger.debug("SettingsMenu closed", "SettingsMenu")

func _on_volume_changed(value: float):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), value == 0)