class_name VFXSpawner
extends Node2D

@export var boost_smoke_scene: PackedScene


func spawn_boost_smoke(
	spawn_position: Vector2,
	boost_direction: Vector2
) -> void:
	if boost_smoke_scene == null:
		push_warning("VFXSpawner: boost_smoke_scene is not assigned.")
		return

	if boost_direction.length_squared() <= 0.0001:
		return

	var effect := boost_smoke_scene.instantiate()

	add_child(effect)

	if effect is BoostSmokeEffect:
		effect.play(spawn_position, boost_direction)
	else:
		push_warning("VFXSpawner: boost_smoke_scene is not BoostSmokeEffect.")
		effect.queue_free()
