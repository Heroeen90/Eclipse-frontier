extends Node

class_name TestSaveSystem

var tests_passed = 0
var tests_failed = 0

func run_all_tests():
	print("=== Running Save System Tests ===")
	
	test_save_and_load()
	test_checksum_verification()
	test_corrupted_save()
	test_backup_creation()
	test_save_validation()
	
	print("=== Save System Tests Complete ===")
	print("Passed: %d | Failed: %d" % [tests_passed, tests_failed])

func test_save_and_load():
	var save_system = SaveSystem.new()
	save_system._ready()
	
	var test_data = {
		"level": 5,
		"playtime": 120.0,
		"player": {"health": 80, "level": 5},
		"inventory": {},
		"quests": {},
		"resources": {"wood": 50}
	}
	
	var saved = save_system.save_game(test_data, 99)
	assert_true(saved, "Game should save successfully")
	
	var loaded = save_system.load_game(99)
	assert_false(loaded.is_empty(), "Loaded data should not be empty")
	assert_equal(loaded.get("level"), 5, "Level should match after load")
	
	# Cleanup test save
	save_system.delete_save(99)
	
	print("✅ test_save_and_load passed")

func test_checksum_verification():
	var checksum1 = ChecksumUtil.calculate_checksum("Hello World")
	var checksum2 = ChecksumUtil.calculate_checksum("Hello World")
	var checksum3 = ChecksumUtil.calculate_checksum("Different Text")
	
	assert_equal(checksum1, checksum2, "Same content should produce same checksum")
	assert_true(checksum1 != checksum3, "Different content should produce different checksum")
	
	var valid = ChecksumUtil.verify_checksum("Hello World", checksum1)
	assert_true(valid, "Checksum should verify correctly")
	
	var invalid = ChecksumUtil.verify_checksum("Modified Content", checksum1)
	assert_false(invalid, "Modified content should fail checksum")
	
	print("✅ test_checksum_verification passed")

func test_corrupted_save():
	var save_system = SaveSystem.new()
	save_system._ready()
	
	# Write corrupted data
	var corrupted_path = "user://corrupted_test.dat"
	var file = FileAccess.open(corrupted_path, FileAccess.WRITE)
	file.store_string("CORRUPTED_DATA_NOT_VALID_JSON")
	
	var validator = SaveValidator.new()
	validator._ready()
	
	var valid = validator.validate_save_file(corrupted_path)
	assert_false(valid, "Corrupted save should fail validation")
	
	# Cleanup
	DirAccess.remove_absolute(corrupted_path)
	
	print("✅ test_corrupted_save passed")

func test_backup_creation():
	var save_system = SaveSystem.new()
	save_system._ready()
	save_system.backup_enabled = true
	
	var test_data = {
		"level": 1,
		"playtime": 0.0,
		"player": {},
		"inventory": {},
		"quests": {},
		"resources": {}
	}
	
	# Save twice to trigger backup
	save_system.save_game(test_data, 98)
	save_system.save_game(test_data, 98)
	
	var backup_path = "user://save_98_backup.dat"
	assert_true(FileAccess.file_exists(backup_path), "Backup file should exist")
	
	# Cleanup
	save_system.delete_save(98)
	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(backup_path)
	
	print("✅ test_backup_creation passed")

func test_save_validation():
	var validator = SaveValidator.new()
	validator._ready()
	
	# Valid data
	var valid_data = {
		"version": "0.1.0",
		"timestamp": "2024-01-01",
		"player": {"level": 1, "health": 100}
	}
	valid_data["checksum"] = ChecksumUtil.calculate_dict_checksum(valid_data)
	
	var is_valid = validator.validate_save_data(valid_data)
	assert_true(is_valid, "Valid data should pass validation")
	
	# Invalid data (missing version)
	var invalid_data = {"player": {}}
	invalid_data["checksum"] = ChecksumUtil.calculate_dict_checksum(invalid_data)
	
	var is_invalid = validator.validate_save_data(invalid_data)
	assert_false(is_invalid, "Invalid data should fail validation")
	
	print("✅ test_save_validation passed")

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