class_name ImpactPredictor
extends Node

var _predictions: Array[Dictionary] = []

@onready var shape_cast: ShapeCast2D = $ImpactShapeCast


func update_predictions(motion: Vector2) -> void:
	_predictions.clear()

	if motion.length_squared() <= 0.0001:
		return

	shape_cast.target_position = motion
	shape_cast.force_shapecast_update()

	if not shape_cast.is_colliding():
		return

	var collision_count := shape_cast.get_collision_count()

	for index in range(collision_count):
		var collider := shape_cast.get_collider(index) as Node
		var target := _find_damage_target(collider)

		if target == null:
			continue

		if not target.has_method("take_damage"):
			continue

		var impact_position := shape_cast.get_collision_point(index)
		var impact_normal := shape_cast.get_collision_normal(index)

		if impact_normal.length_squared() <= 0.0001:
			impact_normal = _get_fallback_impact_normal(
				target,
				impact_position,
				motion
			)

		_predictions.append({
			"target": target,
			"position": impact_position,
			"normal": impact_normal.normalized()
		})


func get_prediction_for_target(target: Node) -> Dictionary:
	for prediction in _predictions:
		if prediction.get("target") == target:
			return prediction

	return {}


func _find_damage_target(collider: Node) -> Node:
	if collider == null:
		return null

	if collider.has_method("take_damage"):
		return collider

	var current := collider.get_parent()

	while current != null:
		if current.has_method("take_damage"):
			return current

		current = current.get_parent()

	return collider


func _get_fallback_impact_normal(
	target: Node,
	impact_position: Vector2,
	motion: Vector2
) -> Vector2:
	var target_node := target as Node2D

	if target_node != null:
		var normal := impact_position - target_node.global_position

		if normal.length_squared() > 0.0001:
			return normal.normalized()

	if motion.length_squared() > 0.0001:
		return -motion.normalized()

	return Vector2.RIGHT
