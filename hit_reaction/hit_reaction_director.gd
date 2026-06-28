class_name HitReactionDirector
extends Node

signal camera_shake_requested(
	strength_ratio: float,
	direction: Vector2
)

@export_range(0.0, 10000.0, 100.0) var min_speed: float = 500.0
@export_range(0.0, 20000.0, 100.0) var max_speed: float = 7000.0

@export_range(0.0, 0.1, 0.002) var min_duration: float = 0.01
@export_range(0.0, 0.1, 0.002) var max_duration: float = 0.034

@export_range(0.0, 2.0, 0.05) var attacker_duration_multiplier: float = 1.0
@export_range(0.0, 2.0, 0.05) var target_duration_multiplier: float = 1.0

@export_group("Camera Shake")
@export var camera_shake_enabled: bool = true
@export_range(0.0, 1.0, 0.05) var camera_shake_min_strength: float = 0.35


func play_hit_reaction(
	target: Node,
	attacker: Node,
	damage_info: DamageInfo
) -> void:
	if target == null or attacker == null:
		return

	var speed := _get_speed(damage_info)
	var strength_ratio := _get_strength_ratio(speed)
	var direction := _get_hit_direction(target, attacker, damage_info)

	var duration := lerpf(
		min_duration,
		max_duration,
		strength_ratio
	)

	_request_hit_stop(
		attacker,
		duration * attacker_duration_multiplier
	)

	_request_hit_stop(
		target,
		duration * target_duration_multiplier
	)

	if camera_shake_enabled and strength_ratio >= camera_shake_min_strength:
		camera_shake_requested.emit(
			strength_ratio,
			direction
		)


func _request_hit_stop(
	node: Node,
	duration: float
) -> void:
	if node == null:
		return

	if duration <= 0.0:
		return

	if not node.has_method("request_hit_stop"):
		return

	node.request_hit_stop(duration)


func _get_speed(damage_info: DamageInfo) -> float:
	if damage_info == null:
		return 0.0

	return absf(damage_info.speed)


func _get_strength_ratio(speed: float) -> float:
	if is_equal_approx(min_speed, max_speed):
		if speed >= max_speed:
			return 1.0

		return 0.0

	var ratio := inverse_lerp(
		min_speed,
		max_speed,
		speed
	)

	return clampf(ratio, 0.0, 1.0)


func _get_hit_direction(
	target: Node,
	attacker: Node,
	damage_info: DamageInfo
) -> Vector2:
	if damage_info != null:
		var damage_direction := damage_info.direction

		if damage_direction.length_squared() > 0.0001:
			return damage_direction.normalized()

	if attacker != null and attacker.has_method("get_velocity_direction"):
		var attacker_direction = attacker.get_velocity_direction()

		if attacker_direction is Vector2:
			var direction := attacker_direction as Vector2

			if direction.length_squared() > 0.0001:
				return direction.normalized()

	var target_node := target as Node2D
	var attacker_node := attacker as Node2D

	if target_node != null and attacker_node != null:
		var fallback := target_node.global_position - attacker_node.global_position

		if fallback.length_squared() > 0.0001:
			return fallback.normalized()

	return Vector2.RIGHT
