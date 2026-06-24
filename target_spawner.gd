class_name TargetSpawner
extends Node


@export var target_scene: PackedScene
@export var avoid_node: Node2D

@export_group("Spawn")
@export_range(1, 100, 1) var target_count: int = 30
@export_range(0.0, 300.0, 10.0) var spawn_margin: float = 100.0
@export_range(0.0, 300.0, 5.0) var min_distance: float = 100.0
@export_range(0.0, 300.0, 10.0) var avoid_node_distance: float = 120.0
@export_range(1, 1000, 1) var max_spawn_attempts: int = 200

@export_group("Respawn")
@export_range(0.0, 5.0, 0.1) var respawn_delay: float = 0.0

var targets: Array[Target] = []


func _ready() -> void:
	spawn_initial_targets()


func spawn_initial_targets() -> void:
	if target_scene == null:
		push_warning("TargetSpawner: target_scene is not assigned.")
		return

	for i in target_count:
		_spawn_target()


func _spawn_target() -> void:
	var target := target_scene.instantiate() as Target

	if target == null:
		push_warning("TargetSpawner: target_scene is not Target.")
		return

	add_child(target)

	var spawn_position := _find_valid_spawn_position()
	target.global_position = spawn_position

	target.destroyed.connect(_on_target_destroyed)

	targets.append(target)


func _on_target_destroyed(target: Target) -> void:
	targets.erase(target)

	if respawn_delay <= 0.0:
		call_deferred("_spawn_target")
		return

	await get_tree().create_timer(respawn_delay).timeout
	_spawn_target()


func _find_valid_spawn_position() -> Vector2:
	for attempt in max_spawn_attempts:
		var candidate := _get_random_position_in_viewport()

		if _is_position_valid(candidate):
			return candidate

	push_warning("TargetSpawner: Failed to find non-overlapping position. Using random fallback.")
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


func _is_position_valid(position: Vector2) -> bool:
	if avoid_node != null:
		if position.distance_to(avoid_node.global_position) < avoid_node_distance:
			return false

	for target in targets:
		if not is_instance_valid(target):
			continue

		var distance := position.distance_to(target.global_position)

		if distance < min_distance:
			return false

	return true
