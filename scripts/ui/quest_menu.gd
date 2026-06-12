extends Control

class_name QuestMenu

@onready var active_quests_list = $VBoxContainer/TabContainer/ActiveQuests/QuestList
@onready var completed_quests_list = $VBoxContainer/TabContainer/CompletedQuests/QuestList
@onready var quest_details_panel = $VBoxContainer/QuestDetailsPanel
@onready var close_button = $VBoxContainer/CloseButton

var quest_manager: QuestManager
var selected_quest: Quest = null

var _logger: Logger
var _event_bus: EventBus

func _ready():
	_logger = GameManager.instance.logger
	_event_bus = GameManager.instance.event_bus
	quest_manager = GameManager.instance.quest_manager
	
	_setup_ui()
	_connect_signals()
	
	_logger.info("QuestMenu initialized", "QuestMenu")

func _setup_ui():
	close_button.pressed.connect(_on_close_pressed)
	_refresh_quest_lists()

func _connect_signals():
	_event_bus.quest_started.connect(_on_quest_event)
	_event_bus.quest_completed.connect(_on_quest_event)
	_event_bus.quest_failed.connect(_on_quest_event)

func _refresh_quest_lists():
	# Clear existing items
	for child in active_quests_list.get_children():
		child.queue_free()
	for child in completed_quests_list.get_children():
		child.queue_free()
	
	# Add active quests
	for quest in quest_manager.get_active_quests():
		var button = Button.new()
		button.text = quest.quest_title
		button.custom_minimum_size = Vector2(200, 30)
		button.pressed.connect(_on_quest_selected.bindv([quest]))
		active_quests_list.add_child(button)
	
	# Add completed quests
	for quest_id in quest_manager.completed_quests:
		var quest = quest_manager.get_quest(quest_id)
		if quest:
			var button = Button.new()
			button.text = quest.quest_title + " (Complete)"
			button.custom_minimum_size = Vector2(200, 30)
			button.pressed.connect(_on_quest_selected.bindv([quest]))
			completed_quests_list.add_child(button)

func _on_quest_selected(quest: Quest):
	selected_quest = quest
	_update_quest_details()

func _update_quest_details():
	if not selected_quest:
		quest_details_panel.text = "Select a quest to view details"
		return
	
	var details = "%s\n" % selected_quest.quest_title
	details += "Status: %s\n\n" % Quest.QuestStatus.keys()[selected_quest.status]
	details += "%s\n\n" % selected_quest.quest_description
	details += "Progress: %.0f%%\n" % (selected_quest.get_progress_percentage() * 100)
	
	if not selected_quest.objectives.is_empty():
		details += "\nObjectives:\n"
		for i in range(selected_quest.objectives.size()):
			var objective = selected_quest.objectives[i]
			details += "- %s\n" % objective.get("description", "")
	
	quest_details_panel.text = details

func _on_quest_event(_quest_id: String):
	_refresh_quest_lists()

func _on_close_pressed():
	visible = false
	_logger.debug("QuestMenu closed", "QuestMenu")