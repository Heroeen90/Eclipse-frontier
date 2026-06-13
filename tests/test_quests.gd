extends Node

class_name TestQuests

var tests_passed = 0
var tests_failed = 0

func run_all_tests():
	print("=== Running Quest Tests ===")
	
	test_quest_creation()
	test_quest_start()
	test_quest_progress()
	test_quest_completion()
	test_quest_failure()
	test_quest_rewards()
	
	print("=== Quest Tests Complete ===")
	print("Passed: %d | Failed: %d" % [tests_passed, tests_failed])

func test_quest_creation():
	var quest = Quest.new("q001", "Test Quest", Quest.QuestType.MAIN)
	quest.quest_description = "A test quest"
	
	assert_equal(quest.quest_id, "q001", "Quest ID should match")
	assert_equal(quest.quest_title, "Test Quest", "Quest title should match")
	assert_equal(quest.status, Quest.QuestStatus.NOT_STARTED, "Initial status should be NOT_STARTED")
	
	print("✅ test_quest_creation passed")

func test_quest_start():
	var quest = Quest.new("q002", "Start Test", Quest.QuestType.SIDE)
	
	quest.start()
	assert_equal(quest.status, Quest.QuestStatus.IN_PROGRESS, "Quest should be IN_PROGRESS after start")
	
	print("✅ test_quest_start passed")

func test_quest_progress():
	var quest = Quest.new("q003", "Progress Test", Quest.QuestType.SIDE)
	quest.add_objective("Collect wood", "collect")
	quest.objectives[0]["target"] = 10
	
	quest.start()
	quest.update_objective_progress(0, 5)
	
	assert_equal(quest.objectives[0]["progress"], 5, "Objective progress should be 5")
	assert_false(quest.objectives[0]["completed"], "Objective should not be completed yet")
	
	quest.update_objective_progress(0, 5)
	assert_true(quest.objectives[0]["completed"], "Objective should be completed")
	
	print("✅ test_quest_progress passed")

func test_quest_completion():
	var quest = Quest.new("q004", "Complete Test", Quest.QuestType.MAIN)
	quest.add_objective("Build house", "build")
	quest.objectives[0]["target"] = 1
	
	quest.start()
	quest.update_objective_progress(0, 1)
	quest.complete()
	
	assert_equal(quest.status, Quest.QuestStatus.COMPLETED, "Quest should be COMPLETED")
	assert_equal(quest.get_progress_percentage(), 1.0, "Progress should be 100%")
	
	print("✅ test_quest_completion passed")

func test_quest_failure():
	var quest = Quest.new("q005", "Fail Test", Quest.QuestType.SIDE)
	quest.start()
	quest.fail()
	
	assert_equal(quest.status, Quest.QuestStatus.FAILED, "Quest should be FAILED")
	
	print("✅ test_quest_failure passed")

func test_quest_rewards():
	var rewards = QuestRewards.new()
	
	rewards.add_experience_reward(100)
	rewards.add_resource_reward("wood", 20)
	rewards.add_resource_reward("stone", 10)
	
	assert_equal(rewards.experience_reward, 100, "Experience reward should be 100")
	assert_equal(rewards.resource_rewards["wood"], 20, "Wood reward should be 20")
	assert_equal(rewards.resource_rewards["stone"], 10, "Stone reward should be 10")
	
	var dict = rewards.to_dict()
	assert_equal(dict["experience"], 100, "Serialized experience should match")
	
	print("✅ test_quest_rewards passed")

func assert_true(condition: bool, message: String):
	if condition:
		tests_passed += 1
	else:
		tests_failed += 1
		print("❌ FAIL: %s" % message)

func assert_false(condition: bool, message: String):
	assert_true(!condition, message)

func assert_equal(value, expected, message: String):
	assert_true(value == expected, "%s (expected: %s, got: %s)" % [message, expected, value])