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
	var hit_direction := _get_hit_direction(target, attacker, damage_info)

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

	var impact_data := _resolve_impact_data(
		target,
		attacker,
		damage_info,
		hit_direction
	)

	var impact_position: Vector2 = impact_data["position"]
	var impact_normal: Vector2 = impact_data["normal"]

	if spark_enabled and strength_ratio >= spark_min_strength:
		impact_spark_requested.emit(
			impact_position,
			impact_normal,
			strength_ratio
		)

	if camera_shake_enabled and strength_ratio >= camera_shake_min_strength:
		camera_shake_requested.emit(
			strength_ratio,
			hit_direction
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
			var direction: Vector2 = value

			if direction.length_squared() > 0.0001:
				return direction.normalized()

	var target_node := target as Node2D
	var attacker_node := attacker as Node2D

	if target_node != null and attacker_node != null:
		var fallback := target_node.global_position - attacker_node.global_position

		if fallback.length_squared() > 0.0001:
			return fallback.normalized()

	return Vector2.RIGHT


func _resolve_impact_data(
	target: Node,
	attacker: Node,
	damage_info: Dictionary,
	hit_direction: Vector2
) -> Dictionary:
	if damage_info.has("impact_position"):
		var position_value = damage_info["impact_position"]

		if position_value is Vector2:
			var impact_position: Vector2 = position_value
			var impact_normal := _resolve_impact_normal(
				target,
				damage_info,
				impact_position,
				hit_direction
			)

			return _make_impact_data(
				impact_position,
				impact_normal
			)

	return _get_fallback_impact_data(
		target,
		attacker,
		hit_direction
	)


func _resolve_impact_normal(
	target: Node,
	damage_info: Dictionary,
	impact_position: Vector2,
	hit_direction: Vector2
) -> Vector2:
	var target_node := target as Node2D

	if target_node != null:
		var normal_from_target := impact_position - target_node.global_position

		if normal_from_target.length_squared() > 0.0001:
			return normal_from_target.normalized()

	if damage_info.has("impact_normal"):
		var normal_value = damage_info["impact_normal"]

		if normal_value is Vector2:
			var impact_normal: Vector2 = normal_value

			if impact_normal.length_squared() > 0.0001:
				return impact_normal.normalized()

	if hit_direction.length_squared() > 0.0001:
		return -hit_direction.normalized()

	return Vector2.RIGHT


func _get_fallback_impact_data(
	target: Node,
	attacker: Node,
	hit_direction: Vector2
) -> Dictionary:
	var target_node := target as Node2D

	if target_node == null:
		var attacker_node := attacker as Node2D

		if attacker_node != null:
			return _make_impact_data(
				attacker_node.global_position,
				_get_safe_direction(-hit_direction)
			)

		return _make_impact_data(
			Vector2.ZERO,
			_get_safe_direction(-hit_direction)
		)

	var radius := 0.0

	if target.has_method("get_target_radius"):
		radius = float(target.get_target_radius())

	var normal := _get_safe_direction(-hit_direction)
	var impact_position := target_node.global_position + normal * radius

	return _make_impact_data(
		impact_position,
		normal
	)


func _get_safe_direction(direction: Vector2) -> Vector2:
	if direction.length_squared() <= 0.0001:
		return Vector2.RIGHT

	return direction.normalized()


func _make_impact_data(
	position: Vector2,
	normal: Vector2
) -> Dictionary:
	return {
		"position": position,
		"normal": _get_safe_direction(normal)
	}
