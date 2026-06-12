extends Node

class_name PlayerAnimation

var animation_player: AnimationPlayer
var sprite_2d: Sprite2D

var current_animation = "idle"
var is_facing_right = true

func _ready():
	animation_player = get_parent().get_node("AnimationPlayer")
	sprite_2d = get_parent().get_node("Sprite2D")
	
	_setup_animations()

func _setup_animations():
	if not animation_player.has_animation("idle"):
		animation_player.add_animation("idle", _create_empty_animation())
	if not animation_player.has_animation("walk"):
		animation_player.add_animation("walk", _create_empty_animation())
	if not animation_player.has_animation("run"):
		animation_player.add_animation("run", _create_empty_animation())

func _create_empty_animation() -> Animation:
	var animation = Animation.new()
	animation.length = 1.0
	return animation

func play_animation(animation_name: String):
	if current_animation != animation_name:
		current_animation = animation_name
		animation_player.play(animation_name)

func set_facing_direction(direction: Vector2):
	if direction.x > 0:
		is_facing_right = true
		sprite_2d.flip_h = false
	elif direction.x < 0:
		is_facing_right = false
		sprite_2d.flip_h = true

func get_current_animation() -> String:
	return current_animation

func is_animation_playing() -> bool:
	return animation_player.is_playing()