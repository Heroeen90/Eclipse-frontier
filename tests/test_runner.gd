extends SceneTree

var total_passed = 0
var total_failed = 0

func _init():
	print("")
	print("╔══════════════════════════════════╗")
	print("║   Eclipse Frontier Test Runner   ║")
	print("╚══════════════════════════════════╝")
	print("")
	
	_run_all_tests()
	_print_summary()
	
	quit()

func _run_all_tests():
	# Player Tests
	var player_tests = TestPlayer.new()
	player_tests.run_all_tests()
	total_passed += player_tests.tests_passed
	total_failed += player_tests.tests_failed
	print("")
	
	# Inventory Tests
	var inventory_tests = TestInventory.new()
	inventory_tests.run_all_tests()
	total_passed += inventory_tests.tests_passed
	total_failed += inventory_tests.tests_failed
	print("")
	
	# Save System Tests
	var save_tests = TestSaveSystem.new()
	save_tests.run_all_tests()
	total_passed += save_tests.tests_passed
	total_failed += save_tests.tests_failed
	print("")
	
	# Quest Tests
	var quest_tests = TestQuests.new()
	quest_tests.run_all_tests()
	total_passed += quest_tests.tests_passed
	total_failed += quest_tests.tests_failed
	print("")

func _print_summary():
	print("╔══════════════════════════════════╗")
	print("║           TEST SUMMARY           ║")
	print("╠══════════════════════════════════╣")
	print("║ Total Passed:  %-18d║" % total_passed)
	print("║ Total Failed:  %-18d║" % total_failed)
	print("║ Success Rate:  %-17s%%║" % ("%.1f" % (float(total_passed) / float(total_passed + total_failed) * 100.0)))
	print("╚══════════════════════════════════╝")
	
	if total_failed == 0:
		print("")
		print("🎉 ALL TESTS PASSED!")
	else:
		print("")
		print("⚠️  SOME TESTS FAILED - Check output above")