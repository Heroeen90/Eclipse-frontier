extends Control

class_name MainMenu

@onready var start_button = $VBoxContainer/StartButton
@onready var load_button = $VBoxContainer/LoadButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var title_label = $VBoxContainer/TitleLabel
@onready var version_label = $VBoxContainer/VersionLabel

var _logger: Logger
var _event_bus: EventBus

func _ready():
	_logger = GameManager.instance.logger
	_event_bus = GameManager.instance.event_bus
	
	_setup_ui()
	_connect_signals()
	
	title_label.text = Constants.GAME_TITLE
	version_label.text = "v%s" % Constants.GAME_VERSION
	
	_logger.info("MainMenu loaded", "MainMenu")

func _setup_ui():
	# Setup button properties
	start_button.custom_minimum_size = Vector2(200, 50)
	load_button.custom_minimum_size = Vector2(200, 50)
	settings_button.custom_minimum_size = Vector2(200, 50)
	quit_button.custom_minimum_size = Vector2(200, 50)
	
	# Setup fonts
	var font_size = 24
	start_button.add_theme_font_size_override("font_size", font_size)
	load_button.add_theme_font_size_override("font_size", font_size)
	settings_button.add_theme_font_size_override("font_size", font_size)
	quit_button.add_theme_font_size_override("font_size", font_size)

func _connect_signals():
	start_button.pressed.connect(_on_start_pressed)
	load_button.pressed.connect(_on_load_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	_logger.info("Starting new game", "MainMenu")
	_event_bus.emit_ui_notification("Starting new game...", "info")
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")

func _on_load_pressed():
	_logger.info("Loading game", "MainMenu")
	var save_info = GameManager.instance.save_system.get_save_info(0)
	if save_info.is_empty():
		_event_bus.emit_ui_notification("No save file found", "warning")
		return
	
	if GameManager.instance.load_game(0):
		_event_bus.emit_ui_notification("Game loaded successfully", "success")
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	else:
		_event_bus.emit_ui_notification("Failed to load game", "error")

func _on_settings_pressed():
	_logger.info("Opening settings", "MainMenu")
	_event_bus.emit_ui_menu_opened("settings")

func _on_quit_pressed():
	_logger.info("Quitting game", "MainMenu")
	GameManager.instance.quit_game()

func _on_animation_finished():
	_logger.debug("Menu animation finished", "MainMenu")