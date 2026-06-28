class_name TargetSpawner
extends Node

signal target_spawned(target: Target)

@export var target_scene: PackedScene
@export var position_provider_path: NodePath = "SpawnPositionProvider"

@export_range(1, 100, 1) var target_count: int = 30
@export_range(0.0, 5.0, 0.1) var respawn_delay: float = 0.0

var targets: Array[Target] = []

@onready var position_provider: SpawnPositionProvider = get_node_or_null(position_provider_path)


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

	target.global_position = _find_spawn_position()
	target.destroyed.connect(_on_target_destroyed)

	targets.append(target)

	target_spawned.emit(target)


func _on_target_destroyed(target: Target) -> void:
	targets.erase(target)

	if respawn_delay <= 0.0:
		call_deferred("_spawn_target")
		return

	await get_tree().create_timer(respawn_delay).timeout
	_spawn_target()


func _find_spawn_position() -> Vector2:
	if position_provider == null:
		push_warning("TargetSpawner: position_provider is not assigned.")
		return Vector2.ZERO

	return position_provider.find_valid_spawn_position(targets)
