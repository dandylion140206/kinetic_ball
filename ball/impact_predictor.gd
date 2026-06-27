class_name ImpactPredictor
extends Node2D

const EPSILON := 0.0001

@export_range(0.0, 200.0, 1.0) var owner_radius: float = 20.0

var _has_last_motion: bool = false
var _last_motion_from: Vector2 = Vector2.ZERO
var _last_motion_to: Vector2 = Vector2.ZERO
var _last_motion: Vector2 = Vector2.ZERO


func update_predictions(motion: Vector2) -> void:
	_last_motion_from = global_position
	_last_motion_to = global_position + motion
	_last_motion = motion
	_has_last_motion = motion.length_squared() > EPSILON


func get_prediction_for_target(target: Node) -> Dictionary:
	if not _has_last_motion:
		return {}

	if target == null:
		return {}

	var target_node := target as Node2D

	if target_node == null:
		return {}

	var target_radius := _get_target_radius(target)

	if target_radius <= 0.0:
		return {}

	var expanded_radius := target_radius + owner_radius
	var target_center := target_node.global_position

	if _is_point_inside_circle(
		_last_motion_from,
		target_center,
		expanded_radius
	):
		return _make_fallback_prediction(
			target,
			target_center,
			target_radius,
			"segment_circle_inside_fallback"
		)

	var entry_result := _get_segment_circle_entry_point(
		_last_motion_from,
		_last_motion_to,
		target_center,
		expanded_radius
	)

	if not bool(entry_result.get("hit", false)):
		return {}

	var ball_center_at_impact: Vector2 = entry_result.get(
		"point",
		Vector2.ZERO
	)

	var impact_normal := ball_center_at_impact - target_center

	if impact_normal.length_squared() <= EPSILON:
		impact_normal = _get_fallback_normal()

	impact_normal = impact_normal.normalized()

	var impact_position := target_center + impact_normal * target_radius

	return {
		"target": target,
		"position": impact_position,
		"normal": impact_normal,
		"source": "segment_circle"
	}


func _get_target_radius(target: Node) -> float:
	if target.has_method("get_collision_radius"):
		return maxf(
			0.0,
			float(target.get_collision_radius())
		)

	if target.has_method("get_target_radius"):
		return maxf(
			0.0,
			float(target.get_target_radius())
		)

	return 0.0


func _get_segment_circle_entry_point(
	segment_from: Vector2,
	segment_to: Vector2,
	circle_center: Vector2,
	circle_radius: float
) -> Dictionary:
	var segment := segment_to - segment_from
	var segment_length_squared := segment.length_squared()

	if segment_length_squared <= EPSILON:
		return {
			"hit": false
		}

	var from_to_center := segment_from - circle_center

	var a := segment.dot(segment)
	var b := 2.0 * from_to_center.dot(segment)
	var c := from_to_center.dot(from_to_center) - circle_radius * circle_radius

	var discriminant := b * b - 4.0 * a * c

	if discriminant < 0.0:
		return {
			"hit": false
		}

	var sqrt_discriminant := sqrt(discriminant)
	var denominator := 2.0 * a

	var entry_t := (-b - sqrt_discriminant) / denominator
	var exit_t := (-b + sqrt_discriminant) / denominator

	var hit_t := INF

	if entry_t >= 0.0 and entry_t <= 1.0:
		hit_t = entry_t
	elif exit_t >= 0.0 and exit_t <= 1.0:
		hit_t = exit_t

	if hit_t == INF:
		return {
			"hit": false
		}

	return {
		"hit": true,
		"point": segment_from + segment * hit_t,
		"t": hit_t
	}


func _is_point_inside_circle(
	point: Vector2,
	circle_center: Vector2,
	circle_radius: float
) -> bool:
	return point.distance_squared_to(circle_center) <= circle_radius * circle_radius


func _make_fallback_prediction(
	target: Node,
	target_center: Vector2,
	target_radius: float,
	source: String
) -> Dictionary:
	var impact_normal := _get_fallback_normal()
	var impact_position := target_center + impact_normal * target_radius

	return {
		"target": target,
		"position": impact_position,
		"normal": impact_normal,
		"source": source
	}


func _get_fallback_normal() -> Vector2:
	if _last_motion.length_squared() > EPSILON:
		return -_last_motion.normalized()

	return Vector2.RIGHT
