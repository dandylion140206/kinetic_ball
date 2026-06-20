class_name BallMovement
extends Node

@export_range(5000, 30000, 1000) var acceleration: int = 10000
@export_range(1000, 10000, 200) var target_speed: int = 5000
@export_range(1000, 10000, 200) var max_speed: int = 5000

var velocity := Vector2.ZERO


func update_velocity(
	current_position: Vector2,
	target_position: Vector2,
	delta: float
) -> Vector2:
	var dir := (target_position - current_position).normalized()
	var desired_velocity := dir * target_speed

	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	velocity = velocity.limit_length(max_speed)

	return velocity
