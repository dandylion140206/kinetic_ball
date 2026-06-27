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
	fallback_direction: Vector2
) -> Dictionary:
	var target_node := target as Node2D

	if target_node == null:
		return _get_fallback_impact_data(
			target,
			attacker,
			fallback_direction
		)

	var movement_impact := _get_impact_from_movement_segment(
		target,
		attacker,
		damage_info,
		fallback_direction
	)

	if bool(movement_impact["found"]):
		return movement_impact

	return _get_fallback_impact_data(
		target,
		attacker,
		fallback_direction
	)


func _get_impact_from_movement_segment(
	target: Node,
	attacker: Node,
	damage_info: Dictionary,
	fallback_direction: Vector2
) -> Dictionary:
	if not damage_info.has("movement_from"):
		return _make_impact_data(Vector2.ZERO, Vector2.ZERO, false)

	if not damage_info.has("movement_to"):
		return _make_impact_data(Vector2.ZERO, Vector2.ZERO, false)

	var from_value = damage_info["movement_from"]
	var to_value = damage_info["movement_to"]

	if not from_value is Vector2:
		return _make_impact_data(Vector2.ZERO, Vector2.ZERO, false)

	if not to_value is Vector2:
		return _make_impact_data(Vector2.ZERO, Vector2.ZERO, false)

	var movement_from: Vector2 = from_value
	var movement_to: Vector2 = to_value

	if movement_from.distance_squared_to(movement_to) <= 0.0001:
		return _make_impact_data(Vector2.ZERO, Vector2.ZERO, false)

	var target_node := target as Node2D

	if target_node == null:
		return _make_impact_data(Vector2.ZERO, Vector2.ZERO, false)

	var target_center := target_node.global_position
	var target_radius := _get_collision_radius(target)
	var attacker_radius := _get_attacker_radius(attacker, damage_info)

	var combined_radius := target_radius + attacker_radius

	if combined_radius <= 0.0:
		return _make_impact_data(Vector2.ZERO, Vector2.ZERO, false)

	var entry_center_value: Variant = _get_segment_circle_entry_point(
		movement_from,
		movement_to,
		target_center,
		combined_radius
	)

	if entry_center_value == null:
		return _make_impact_data(Vector2.ZERO, Vector2.ZERO, false)

	var entry_center: Vector2 = entry_center_value
	var normal := (entry_center - target_center).normalized()

	if normal.length_squared() <= 0.0001:
		normal = _get_fallback_normal(
			target,
			attacker,
			fallback_direction
		)

	var impact_position := target_center + normal * target_radius

	return _make_impact_data(
		impact_position,
		normal,
		true
	)


func _get_segment_circle_entry_point(
	segment_from: Vector2,
	segment_to: Vector2,
	circle_center: Vector2,
	circle_radius: float
) -> Variant:
	var segment := segment_to - segment_from
	var from_to_center := segment_from - circle_center

	var a := segment.dot(segment)

	if a <= 0.0001:
		return null

	var b := 2.0 * from_to_center.dot(segment)
	var c := from_to_center.dot(from_to_center) - circle_radius * circle_radius

	var discriminant := b * b - 4.0 * a * c

	if discriminant < 0.0:
		return null

	var sqrt_discriminant := sqrt(discriminant)
	var t1 := (-b - sqrt_discriminant) / (2.0 * a)
	var t2 := (-b + sqrt_discriminant) / (2.0 * a)

	var entry_t := INF

	if t1 >= 0.0 and t1 <= 1.0:
		entry_t = minf(entry_t, t1)

	if t2 >= 0.0 and t2 <= 1.0:
		entry_t = minf(entry_t, t2)

	if entry_t == INF:
		return null

	return segment_from + segment * entry_t


func _get_fallback_impact_data(
	target: Node,
	attacker: Node,
	fallback_direction: Vector2
) -> Dictionary:
	var target_node := target as Node2D

	if target_node == null:
		var attacker_node := attacker as Node2D

		if attacker_node != null:
			return _make_impact_data(
				attacker_node.global_position,
				_get_safe_direction(fallback_direction),
				false
			)

		return _make_impact_data(
			Vector2.ZERO,
			_get_safe_direction(fallback_direction),
			false
		)

	var normal := _get_fallback_normal(
		target,
		attacker,
		fallback_direction
	)

	var target_radius := _get_collision_radius(target)
	var impact_position := target_node.global_position + normal * target_radius

	return _make_impact_data(
		impact_position,
		normal,
		false
	)


func _get_fallback_normal(
	target: Node,
	attacker: Node,
	fallback_direction: Vector2
) -> Vector2:
	var target_node := target as Node2D
	var attacker_node := attacker as Node2D

	if target_node != null and attacker_node != null:
		var normal := attacker_node.global_position - target_node.global_position

		if normal.length_squared() > 0.0001:
			return normal.normalized()

	var safe_direction := _get_safe_direction(fallback_direction)

	return -safe_direction


func _get_safe_direction(direction: Vector2) -> Vector2:
	if direction.length_squared() <= 0.0001:
		return Vector2.RIGHT

	return direction.normalized()


func _get_collision_radius(node: Node) -> float:
	if node == null:
		return 0.0

	if node.has_method("get_collision_radius"):
		return float(node.get_collision_radius())

	if node.has_method("get_target_radius"):
		return float(node.get_target_radius())

	return 0.0


func _get_attacker_radius(
	attacker: Node,
	damage_info: Dictionary
) -> float:
	if damage_info.has("attacker_radius"):
		return float(damage_info["attacker_radius"])

	return _get_collision_radius(attacker)


func _make_impact_data(
	position: Vector2,
	normal: Vector2,
	found: bool
) -> Dictionary:
	return {
		"position": position,
		"normal": _get_safe_direction(normal),
		"found": found
	}
