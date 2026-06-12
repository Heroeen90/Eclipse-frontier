extends Enemy

class_name Boss

var phase: int = 1
var max_phases: int = 3

func _ready():
	enemy_type = EnemyType.BOSS
	enemy_name = "Boss"
	max_health = 200.0
	current_health = max_health
	attack_damage = 15.0
	speed = 80.0
	detection_range = 300.0
	attack_range = 60.0
	experience_reward = 500
	_attack_cooldown_max = 2.0
	
	super._ready()

func _update_behavior(delta):
	super._update_behavior(delta)
	
	if is_alive:
		_check_phase_change()

func _check_phase_change():
	var health_percentage = get_health_percentage()
	
	if health_percentage < 0.33 and phase < 3:
		phase = 3
		speed = 120.0
		attack_damage = 20.0
		_logger.info("Boss entered phase 3", "Boss")
	elif health_percentage < 0.66 and phase < 2:
		phase = 2
		speed = 110.0
		attack_damage = 17.0
		_logger.info("Boss entered phase 2", "Boss")

func die():
	_logger.info("Boss defeated!", "Boss")
	GameManager.instance.end_game(true)
	super.die()