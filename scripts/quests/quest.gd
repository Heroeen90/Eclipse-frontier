extends Node

class_name Quest

enum QuestStatus { NOT_STARTED, IN_PROGRESS, COMPLETED, FAILED }
enum QuestType { MAIN, SIDE, DAILY }

var quest_id: String
var quest_title: String
var quest_description: String
var quest_type: QuestType
var status: QuestStatus = QuestStatus.NOT_STARTED

var objectives: Array[Dictionary] = []
var current_objective_index = 0
var progress = 0.0

var requirements: Dictionary = {}
var rewards: Dictionary = {}
var quest_giver: String = ""

var is_repeatable = false
var start_time = 0.0
var completion_time = 0.0

func _init(
	p_id: String = "",
	p_title: String = "",
	p_type: QuestType = QuestType.MAIN
):
	quest_id = p_id
	quest_title = p_title
	quest_type = p_type

func start():
	if status == QuestStatus.NOT_STARTED:
		status = QuestStatus.IN_PROGRESS
		start_time = Time.get_ticks_msec()
		progress = 0.0

func complete():
	if status == QuestStatus.IN_PROGRESS:
		status = QuestStatus.COMPLETED
		completion_time = Time.get_ticks_msec()
		progress = 1.0

func fail():
	status = QuestStatus.FAILED

func add_objective(objective_description: String, objective_type: String = "kill"):
	objectives.append({
		"description": objective_description,
		"type": objective_type,
		"progress": 0,
		"target": 1,
		"completed": false
	})

func update_objective_progress(objective_index: int, progress_amount: float):
	if objective_index < objectives.size():
		objectives[objective_index]["progress"] = min(
			objectives[objective_index]["progress"] + progress_amount,
			objectives[objective_index]["target"]
		)
		
		if objectives[objective_index]["progress"] >= objectives[objective_index]["target"]:
			objectives[objective_index]["completed"] = true

func get_current_objective() -> Dictionary:
	if current_objective_index < objectives.size():
		return objectives[current_objective_index]
	return {}

func is_all_objectives_complete() -> bool:
	for objective in objectives:
		if not objective.get("completed", false):
			return false
	return true

func get_progress_percentage() -> float:
	if objectives.is_empty():
		return 0.0
	
	var completed = 0
	for objective in objectives:
		if objective.get("completed", false):
			completed += 1
	
	return float(completed) / float(objectives.size())

func get_duration() -> float:
	if completion_time > 0:
		return (completion_time - start_time) / 1000.0
	return (Time.get_ticks_msec() - start_time) / 1000.0

func to_dict() -> Dictionary:
	return {
		"quest_id": quest_id,
		"quest_title": quest_title,
		"quest_description": quest_description,
		"quest_type": quest_type,
		"status": status,
		"objectives": objectives,
		"current_objective_index": current_objective_index,
		"progress": progress,
		"requirements": requirements,
		"rewards": rewards,
		"quest_giver": quest_giver,
		"is_repeatable": is_repeatable
	}

func from_dict(data: Dictionary):
	quest_id = data.get("quest_id", "")
	quest_title = data.get("quest_title", "")
	quest_description = data.get("quest_description", "")
	quest_type = data.get("quest_type", QuestType.MAIN)
	status = data.get("status", QuestStatus.NOT_STARTED)
	objectives = data.get("objectives", [])
	current_objective_index = data.get("current_objective_index", 0)
	progress = data.get("progress", 0.0)
	requirements = data.get("requirements", {})
	rewards = data.get("rewards", {})
	quest_giver = data.get("quest_giver", "")
	is_repeatable = data.get("is_repeatable", false)