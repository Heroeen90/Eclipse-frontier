extends Enemy

class_name Goblin

func _ready():
	enemy_type = EnemyType.GOBLIN
	enemy_name = "Goblin"
	max_health = 25.0
	current_health = max_health
	attack_damage = 4.0
	speed = 130.0
	detection_range = 180.0
	attack_range = 35.0
	experience_reward = 40
	
	super._ready()