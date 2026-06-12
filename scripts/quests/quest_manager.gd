extends Node

class_name QuestManager

var quests: Dictionary = {}
var active_quests: Array[String] = []
var completed_quests: Array[String] = []

var _logger: Logger
var _event_bus: EventBus

func _ready():
	_logger = GameManager.instance.logger
	_event_bus = GameManager.instance.event_bus
	_load_quests_data()
	_logger.info("QuestManager initialized", "QuestManager")

func _load_quests_data():
	var file = FileAccess.open("res://data/quests_data.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var content = file.get_as_text()
		if json.parse(content) == OK:
			var quests_data = json.get_data()
			for quest_data in quests_data.get("quests", []):
				var quest = Quest.new(
					quest_data.get("id", ""),
					quest_data.get("title", ""),
					quest_data.get("type", Quest.QuestType.MAIN)
				)
				quest.quest_description = quest_data.get("description", "")
				quest.quest_giver = quest_data.get("giver", "")
				quest.rewards = quest_data.get("rewards", {})
				
				quests[quest.quest_id] = quest

func start_quest(quest_id: String) -> bool:
	if quests.has(quest_id):
		var quest = quests[quest_id]
		quest.start()
		active_quests.append(quest_id)
		_event_bus.emit(EventBus.quest_started, quest_id)
		_logger.info("Quest started: %s" % quest.quest_title, "QuestManager")
		return true
	
	_logger.warning("Quest not found: %s" % quest_id, "QuestManager")
	return false

func complete_quest(quest_id: String) -> Dictionary:
	if not quests.has(quest_id):
		return {}
	
	var quest = quests[quest_id]
	if quest.status != Quest.QuestStatus.IN_PROGRESS:
		return {}
	
	quest.complete()
	active_quests.erase(quest_id)
	completed_quests.append(quest_id)
	
	var rewards = quest.rewards
	_apply_quest_rewards(rewards)
	
	_event_bus.emit(EventBus.quest_completed, quest_id)
	_event_bus.emit(EventBus.quest_reward_claimed, quest_id, rewards)
	
	_logger.info("Quest completed: %s" % quest.quest_title, "QuestManager")
	
	return rewards

func fail_quest(quest_id: String) -> bool:
	if not quests.has(quest_id):
		return false
	
	var quest = quests[quest_id]
	quest.fail()
	active_quests.erase(quest_id)
	
	_event_bus.emit(EventBus.quest_failed, quest_id)
	_logger.warning("Quest failed: %s" % quest.quest_title, "QuestManager")
	
	return true

func update_quest_progress(quest_id: String, objective_index: int, progress: float):
	if not quests.has(quest_id):
		return
	
	var quest = quests[quest_id]
	quest.update_objective_progress(objective_index, progress)
	
	_event_bus.emit(EventBus.quest_progress_changed, quest_id, quest.get_progress_percentage())

func get_active_quests() -> Array[Quest]:
	var active = []
	for quest_id in active_quests:
		if quests.has(quest_id):
			active.append(quests[quest_id])
	return active

func get_quest(quest_id: String) -> Quest:
	return quests.get(quest_id, null)

func is_quest_active(quest_id: String) -> bool:
	return quest_id in active_quests

func is_quest_completed(quest_id: String) -> bool:
	return quest_id in completed_quests

func _apply_quest_rewards(rewards: Dictionary):
	var player_stats = GameManager.instance.player_manager
	var resource_manager = GameManager.instance.resource_manager
	
	if rewards.has("experience"):
		player_stats.gain_experience(rewards["experience"])
	
	if rewards.has("gold"):
		# Add gold if system exists
		pass
	
	if rewards.has("resources"):
		for resource_type in rewards["resources"]:
			var amount = rewards["resources"][resource_type]
			resource_manager.add_resource(resource_type, amount)

func reset():
	quests.clear()
	active_quests.clear()
	completed_quests.clear()
	_load_quests_data()

func to_dict() -> Dictionary:
	var quests_data = []
	for quest_id in quests:
		quests_data.append(quests[quest_id].to_dict())
	
	return {
		"quests": quests_data,
		"active_quests": active_quests,
		"completed_quests": completed_quests
	}

func from_dict(data: Dictionary):
	var quests_data = data.get("quests", [])
	for quest_data in quests_data:
		var quest = Quest.new()
		quest.from_dict(quest_data)
		quests[quest.quest_id] = quest
	
	active_quests = data.get("active_quests", [])
	completed_quests = data.get("completed_quests", [])

func update(_delta: float):
	for quest_id in active_quests:
		if quests.has(quest_id):
			var quest = quests[quest_id]
			if quest.is_all_objectives_complete() and quest.status == Quest.QuestStatus.IN_PROGRESS:
				complete_quest(quest_id)