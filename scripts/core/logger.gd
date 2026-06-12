extends Node

class_name Logger

# Singleton pattern
var _instance
var log_file_path = "user://game_logs.txt"
var current_log_level = Constants.LOG_LEVEL_DEBUG
var enable_console_output = true
var enable_file_output = true
var max_log_size = 10485760  # 10 MB

var _log_file: FileAccess
var _current_log_size = 0

func _ready():
	_initialize_log_file()

func _initialize_log_file():
	if enable_file_output:
		var file = FileAccess.open(log_file_path, FileAccess.WRITE)
		if file:
			file.store_line("[Game Start] " + Time.get_datetime_string_from_system())
			_current_log_size = file.get_length()

func _should_log(level: int) -> bool:
	return level >= current_log_level

func _get_level_name(level: int) -> String:
	match level:
		Constants.LOG_LEVEL_DEBUG:
			return "[DEBUG]"
		Constants.LOG_LEVEL_INFO:
			return "[INFO]"
		Constants.LOG_LEVEL_WARNING:
			return "[WARNING]"
		Constants.LOG_LEVEL_ERROR:
			return "[ERROR]"
		Constants.LOG_LEVEL_CRITICAL:
			return "[CRITICAL]"
		_:
			return "[UNKNOWN]"

func _log_to_file(message: String):
	if enable_file_output:
		var file = FileAccess.open(log_file_path, FileAccess.READ_WRITE)
		if file:
			file.seek_end()
			var timestamp = Time.get_datetime_string_from_system()
			var log_entry = "[%s] %s\n" % [timestamp, message]
			file.store_string(log_entry)
			_current_log_size = file.get_length()
			
			if _current_log_size > max_log_size:
				_rotate_log_file()

func _rotate_log_file():
	if FileAccess.file_exists(log_file_path):
		var backup_path = log_file_path.trim_suffix(".txt") + "_backup.txt"
		if FileAccess.file_exists(backup_path):
			DirAccess.remove_absolute(backup_path)
		DirAccess.rename_absolute(log_file_path, backup_path)

func _format_message(level: int, message: String, source: String = "") -> String:
	var level_name = _get_level_name(level)
	var source_str = " [%s]" % source if source else ""
	return "%s%s: %s" % [level_name, source_str, message]

func debug(message: String, source: String = ""):
	if _should_log(Constants.LOG_LEVEL_DEBUG):
		var formatted = _format_message(Constants.LOG_LEVEL_DEBUG, message, source)
		if enable_console_output:
			print(formatted)
		_log_to_file(formatted)

func info(message: String, source: String = ""):
	if _should_log(Constants.LOG_LEVEL_INFO):
		var formatted = _format_message(Constants.LOG_LEVEL_INFO, message, source)
		if enable_console_output:
			print(formatted)
		_log_to_file(formatted)

func warning(message: String, source: String = ""):
	if _should_log(Constants.LOG_LEVEL_WARNING):
		var formatted = _format_message(Constants.LOG_LEVEL_WARNING, message, source)
		if enable_console_output:
			print_rich("[color=yellow]%s[/color]" % formatted)
		_log_to_file(formatted)

func error(message: String, source: String = ""):
	if _should_log(Constants.LOG_LEVEL_ERROR):
		var formatted = _format_message(Constants.LOG_LEVEL_ERROR, message, source)
		if enable_console_output:
			print_rich("[color=red]%s[/color]" % formatted)
		_log_to_file(formatted)

func critical(message: String, source: String = ""):
	if _should_log(Constants.LOG_LEVEL_CRITICAL):
		var formatted = _format_message(Constants.LOG_LEVEL_CRITICAL, message, source)
		if enable_console_output:
			print_rich("[color=darkred][bgcolor=yellow]%s[/bgcolor][/color]" % formatted)
		_log_to_file(formatted)

func get_log_content() -> String:
	if FileAccess.file_exists(log_file_path):
		var file = FileAccess.open(log_file_path, FileAccess.READ)
		return file.get_as_text()
	return ""

func clear_logs():
	if FileAccess.file_exists(log_file_path):
		DirAccess.remove_absolute(log_file_path)
	_initialize_log_file()