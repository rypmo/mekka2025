extends CharacterBody2D
class_name PlayerMovement

@export var speed: float = 160.0

func _physics_process(_delta: float) -> void:
	var dir := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if dir.length_squared() > 0:
		dir = dir.normalized()

	velocity = dir * speed
	move_and_slide()

