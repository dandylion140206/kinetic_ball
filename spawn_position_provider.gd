class_name SpawnPositionProvider
extends Node

@export var avoid_node: Node2D

@export_group("Spawn")
@export_range(0.0, 300.0, 10.0) var spawn_margin: float = 100.0
@export_range(0.0, 300.0, 5.0) var min_distance: float = 100.0
@export_range(0.0, 300.0, 10.0) var avoid_node_distance: float = 120.0
@export_range(1, 1000, 1) var max_spawn_attempts: int = 200


func find_valid_spawn_position(existing_nodes: Array) -> Vector2:
	for attempt in max_spawn_attempts:
		var candidate := _get_random_position_in_viewport()

		if _is_position_valid(candidate, existing_nodes):
			return candidate

	push_warning("TargetSpawnPositionProvider: Failed to find non-overlapping position. Using random fallback.")
	return _get_random_position_in_viewport()


func _get_random_position_in_viewport() -> Vector2:
	var viewport_rect := get_viewport().get_visible_rect()

	var min_x := viewport_rect.position.x + spawn_margin
	var max_x := viewport_rect.position.x + viewport_rect.size.x - spawn_margin
	var min_y := viewport_rect.position.y + spawn_margin
	var max_y := viewport_rect.position.y + viewport_rect.size.y - spawn_margin

	return Vector2(
		randf_range(min_x, max_x),
		randf_range(min_y, max_y)
	)


func _is_position_valid(
	position: Vector2,
	existing_nodes: Array
) -> bool:
	if avoid_node != null:
		if position.distance_to(avoid_node.global_position) < avoid_node_distance:
			return false

	for node in existing_nodes:
		var node_2d := node as Node2D

		if node_2d == null:
			continue

		if not is_instance_valid(node_2d):
			continue

		var distance := position.distance_to(node_2d.global_position)

		if distance < min_distance:
			return false

	return true
