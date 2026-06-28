class_name BallSteering
extends Node


func calculate_velocity(
	current_velocity: Vector2,
	current_position: Vector2,
	target_position: Vector2,
	steering_stats: BallSteeringStats,
	delta: float
) -> Vector2:
	var to_target := target_position - current_position

	var target_velocity := Vector2.ZERO

	if to_target.length_squared() > 0.0001:
		var direction := to_target.normalized()
		target_velocity = direction * steering_stats.target_speed

	var new_velocity := current_velocity.move_toward(
		target_velocity,
		steering_stats.acceleration * delta
	)

	new_velocity = new_velocity.limit_length(steering_stats.max_speed)

	return new_velocity
