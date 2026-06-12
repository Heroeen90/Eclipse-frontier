extends CharacterBody2D

class_name Enemy

enum EnemyType { SKELETON, GOBLIN, BOSS }

var enemy_type: EnemyType = EnemyType.SKELETON
var enemy_name: String = "Enemy"
var max_health: float = 30.0
var current_health: float = 30.0
var attack_damage: float = 5.0
var speed: float = 100.0
var detection_range: float = 200.0
var attack_range: float = 40.0
var experience_reward: int = 50

var is_alive: bool = true
var target: Node2D = null
var current_state: String = "idle"

var _logger: Logger
var _event_bus: EventBus
var _animation_player: AnimationPlayer
var _attack_cooldown: float = 0.0
var _attack_cooldown_max: float = 1.5

func _ready():
	_logger = GameManager.instance.logger
	_event_bus = GameManager.instance.event_bus
	
	_animation_player = $AnimationPlayer
	
	_connect_signals()

func _connect_signals():
	_event_bus.player_position_changed.connect(_on_player_moved)

func _physics_process(delta):
	if not is_alive:
		return
	
	_update_state()
	_update_behavior(delta)
	move_and_slide()

func _update_state():
	if not target:
		_find_target()
		current_state = "idle"
		return
	
	var distance_to_target = global_position.distance_to(target.global_position)
	
	if distance_to_target > detection_range:
		target = null
		current_state = "idle"
	elif distance_to_target <= attack_range:
		current_state = "attacking"
	else:
		current_state = "chasing"

func _update_behavior(delta):
	match current_state:
		"idle":
			velocity = Vector2.ZERO
			if _animation_player:
				_animation_player.play("idle")
		
		"chasing":
			var direction = (target.global_position - global_position).normalized()
			velocity = direction * speed
			if _animation_player:
				_animation_player.play("walk")
		
		"attacking":
			velocity = Vector2.ZERO
			_attack_cooldown -= delta
			if _attack_cooldown <= 0:
				_attack()
				_attack_cooldown = _attack_cooldown_max
			if _animation_player:
				_animation_player.play("attack")

func _find_target():
	var player_stats = GameManager.instance.player_manager
	if player_stats:
		if global_position.distance_to(player_stats.position) <= detection_range:
			target = player_stats
			_logger.debug("Enemy acquired target", "Enemy")

func _attack():
	if target and target.has_method("take_damage"):
		target.take_damage(attack_damage, enemy_name)
		_logger.debug("Enemy attacked target for %.1f damage" % attack_damage, "Enemy")

func take_damage(damage: float, source: String = "Player"):
	if not is_alive:
		return
	
	current_health -= damage
	_event_bus.emit(EventBus.damage_taken, damage, source)
	
	if current_health <= 0:
		die()

func die():
	is_alive = false
	current_state = "dead"
	
	var player_stats = GameManager.instance.player_manager
	player_stats.gain_experience(experience_reward)
	
	_event_bus.emit_enemy_defeated(enemy_name, experience_reward)
	_logger.info("Enemy defeated: %s" % enemy_name, "Enemy")
	
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_player_moved(position: Vector2):
	if global_position.distance_to(position) <= detection_range:
		target = GameManager.instance.player_manager

func get_health_percentage() -> float:
	return current_health / max_health