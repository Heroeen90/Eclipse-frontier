extends Node

class_name SaveData

var version: String
var timestamp: String
var playtime: float
var level: int
var player: Dictionary
var inventory: Dictionary
var quests: Dictionary
var resources: Dictionary
var checksum: String

func _init():
	version = Constants.GAME_VERSION
	timestamp = Time.get_datetime_string_from_system()
	playtime = 0.0
	level = 1
	player = {}
	inventory = {}
	quests = {}
	resources = {}
	checksum = ""

func to_dict() -> Dictionary:
	var data = {
		"version": version,
		"timestamp": timestamp,
		"playtime": playtime,
		"level": level,
		"player": player,
		"inventory": inventory,
		"quests": quests,
		"resources": resources
	}
	
	# Calculate checksum before adding it
	data["checksum"] = ChecksumUtil.calculate_dict_checksum(data)
	
	return data

func from_dict(data: Dictionary) -> void:
	version = data.get("version", Constants.GAME_VERSION)
	timestamp = data.get("timestamp", Time.get_datetime_string_from_system())
	playtime = data.get("playtime", 0.0)
	level = data.get("level", 1)
	player = data.get("player", {})
	inventory = data.get("inventory", {})
	quests = data.get("quests", {})
	resources = data.get("resources", {})
	checksum = data.get("checksum", "")

func get_save_size() -> int:
	return JSON.stringify(to_dict()).length()

func get_last_save_time() -> String:
	return timestamp