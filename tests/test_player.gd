extends Node

class_name TestPlayer

var tests_passed = 0
var tests_failed = 0

func run_all_tests():
	print("=== Running Player Tests ===")
	
	test_player_initialization()
	test_take_damage()
	test_heal()
	test_energy_system()
	test_experience_gain()
	test_level_up()
	test_player_death()
	test_player_respawn()
	
	print("=== Player Tests Complete ===")
	print("Passed: %d | Failed: %d" % [tests_passed, tests_failed])

func test_player_initialization():
	var player = PlayerStats.new()
	player._ready()
	
	assert_equal(player.current_health, player.max_health, "Initial health should equal max health")
	assert_equal(player.current_energy, player.max_energy, "Initial energy should equal max energy")
	assert_equal(player.current_level, 1, "Initial level should be 1")
	assert_equal(player.current_experience, 0, "Initial experience should be 0")
	assert_true(player.is_alive, "Player should be alive initially")
	
	print("✅ test_player_initialization passed")

func test_take_damage():
	var player = PlayerStats.new()
	player._ready()
	var initial_health = player.current_health
	
	player.take_damage(20.0, "Test")
	
	assert_true(player.current_health < initial_health, "Health should decrease after taking damage")
	assert_true(player.is_alive, "Player should be alive after non-lethal damage")
	
	print("✅ test_take_damage passed")

func test_heal():
	var player = PlayerStats.new()
	player._ready()
	
	player.take_damage(50.0, "Test")
	var health_after_damage = player.current_health
	
	player.heal(30.0)
	
	assert_true(player.current_health > health_after_damage, "Health should increase after healing")
	assert_true(player.current_health <= player.max_health, "Health should not exceed max health")
	
	print("✅ test_heal passed")

func test_energy_system():
	var player = PlayerStats.new()
	player._ready()
	
	var consumed = player.consume_energy(30.0)
	assert_true(consumed, "Energy should be consumed successfully")
	assert_equal(player.current_energy, player.max_energy - 30.0, "Energy should decrease correctly")
	
	player.restore_energy(20.0)
	assert_equal(player.current_energy, player.max_energy - 10.0, "Energy should restore correctly")
	
	var not_enough_energy = player.consume_energy(player.current_energy + 10.0)
	assert_false(not_enough_energy, "Should not consume more energy than available")
	
	print("✅ test_energy_system passed")

func test_experience_gain():
	var player = PlayerStats.new()
	player._ready()
	
	player.gain_experience(50)
	assert_equal(player.current_experience, 50, "Experience should increase correctly")
	
	print("✅ test_experience_gain passed")

func test_level_up():
	var player = PlayerStats.new()
	player._ready()
	
	var initial_level = player.current_level
	player.gain_experience(player.experience_for_next_level)
	
	assert_equal(player.current_level, initial_level + 1, "Player should level up correctly")
	
	print("✅ test_level_up passed")

func test_player_death():
	var player = PlayerStats.new()
	player._ready()
	
	player.take_damage(player.max_health + 100, "Test")
	
	assert_false(player.is_alive, "Player should be dead after lethal damage")
	
	print("✅ test_player_death passed")

func test_player_respawn():
	var player = PlayerStats.new()
	player._ready()
	
	player.take_damage(player.max_health + 100, "Test")
	player.respawn(Vector2(100, 100))
	
	assert_true(player.is_alive, "Player should be alive after respawn")
	assert_equal(player.current_health, player.max_health, "Health should be full after respawn")
	assert_equal(player.position, Vector2(100, 100), "Player should be at respawn position")
	
	print("✅ test_player_respawn passed")

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