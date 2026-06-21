class_name Movement
extends Node


func calculate_velocity(
	current_velocity: Vector2,
	current_position: Vector2,
	target_position: Vector2,
	movement_stats: MovementStats,
	delta: float,
	target_speed_multiplier: float = 1.0,
	acceleration_multiplier: float = 1.0,
	max_speed_multiplier: float = 1.0
) -> Vector2:
	var direction := (target_position - current_position).normalized()

	var target_speed := movement_stats.target_speed * target_speed_multiplier
	var acceleration := movement_stats.acceleration * acceleration_multiplier
	var max_speed := movement_stats.max_speed * max_speed_multiplier

	var desired_velocity := direction * target_speed

	var new_velocity := current_velocity.move_toward(
		desired_velocity,
		acceleration * delta
	)

	new_velocity = new_velocity.limit_length(max_speed)

	return new_velocity
