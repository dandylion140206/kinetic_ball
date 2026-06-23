class_name Movement
extends Node


@export_group("Steering Force")
@export_range(0.1, 2.0, 0.05) var steering_force_multiplier: float = 1.0
@export_range(0.0, 5000.0, 100.0) var steering_drag: float = 0.0
@export_range(0.1, 10.0, 0.1) var velocity_response: float = 6.0


func calculate_velocity(
	current_velocity: Vector2,
	current_position: Vector2,
	target_position: Vector2,
	movement_stats: MovementStats,
	delta: float
) -> Vector2:
	var to_target := target_position - current_position

	if to_target.length_squared() <= 0.0001:
		return _apply_drag(current_velocity, delta)

	var direction := to_target.normalized()

	var desired_velocity := direction * movement_stats.target_speed

	var velocity_error := desired_velocity - current_velocity

	var desired_force := velocity_error * velocity_response

	var max_force := movement_stats.acceleration * steering_force_multiplier
	var force := desired_force.limit_length(max_force)

	var new_velocity := current_velocity + force * delta

	new_velocity = _apply_drag(new_velocity, delta)

	new_velocity = new_velocity.limit_length(movement_stats.max_speed)

	return new_velocity


func _apply_drag(
	current_velocity: Vector2,
	delta: float
) -> Vector2:
	if steering_drag <= 0.0:
		return current_velocity

	return current_velocity.move_toward(
		Vector2.ZERO,
		steering_drag * delta
	)
