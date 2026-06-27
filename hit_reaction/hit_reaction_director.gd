class_name HitReactionDirector
extends Node

signal impact_spark_requested(
	position: Vector2,
	direction: Vector2,
	strength_ratio: float
)

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

@export_group("Impact Spark")
@export var spark_enabled: bool = true
@export_range(0.0, 1.0, 0.05) var spark_min_strength: float = 0.0

@export_group("Camera Shake")
@export var camera_shake_enabled: bool = true
@export_range(0.0, 1.0, 0.05) var camera_shake_min_strength: float = 0.35


func play_hit_reaction(
	target: Node,
	attacker: Node,
	damage_info: Dictionary
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

	var impact_position := _get_impact_position(
		target,
		attacker,
		direction
	)

	if spark_enabled and strength_ratio >= spark_min_strength:
		impact_spark_requested.emit(
			impact_position,
			-direction,
			strength_ratio
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
	var receiver := _find_hit_stop_receiver(node)

	if receiver == null:
		return

	receiver.request_hit_stop(duration)


func _find_hit_stop_receiver(node: Node) -> HitStopReceiver:
	var direct_receiver := node.get_node_or_null("HitStopReceiver") as HitStopReceiver

	if direct_receiver != null:
		return direct_receiver

	for child in node.get_children():
		if child is HitStopReceiver:
			return child

	return null


func _get_speed(damage_info: Dictionary) -> float:
	if not damage_info.has("speed"):
		return 0.0

	return float(damage_info["speed"])


func _get_strength_ratio(speed: float) -> float:
	var ratio := inverse_lerp(
		min_speed,
		max_speed,
		speed
	)

	return clampf(ratio, 0.0, 1.0)


func _get_hit_direction(
	target: Node,
	attacker: Node,
	damage_info: Dictionary
) -> Vector2:
	if damage_info.has("direction"):
		var value = damage_info["direction"]

		if value is Vector2:
			var direction := value as Vector2

			if direction.length_squared() > 0.0001:
				return direction.normalized()

	var target_node := target as Node2D
	var attacker_node := attacker as Node2D

	if target_node != null and attacker_node != null:
		var fallback := target_node.global_position - attacker_node.global_position

		if fallback.length_squared() > 0.0001:
			return fallback.normalized()

	return Vector2.RIGHT


func _get_impact_position(
	target: Node,
	attacker: Node,
	direction: Vector2
) -> Vector2:
	var target_node := target as Node2D

	if target_node == null:
		var attacker_node := attacker as Node2D

		if attacker_node != null:
			return attacker_node.global_position

		return Vector2.ZERO

	var radius := 0.0

	if target.has_method("get_target_radius"):
		radius = float(target.get_target_radius())

	return target_node.global_position - direction.normalized() * radius
