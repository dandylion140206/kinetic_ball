class_name HealthBarLayer
extends Node2D

@export var health_bar_scene: PackedScene

var bars_by_target: Dictionary = {}


func register_target(target: Target) -> void:
	if target == null:
		return

	if health_bar_scene == null:
		push_warning("HealthBarLayer: health_bar_scene is not assigned.")
		return

	if bars_by_target.has(target):
		return

	var health_bar := health_bar_scene.instantiate() as HealthBar

	if health_bar == null:
		push_warning("HealthBarLayer: health_bar_scene is not HealthBar.")
		return

	add_child(health_bar)

	health_bar.setup(target, target.get_hp_ratio())
	bars_by_target[target] = health_bar

	target.health_ratio_changed.connect(_on_target_health_ratio_changed)
	target.destroyed.connect(_on_target_destroyed)


func _on_target_health_ratio_changed(target: Target, hp_ratio: float) -> void:
	if not bars_by_target.has(target):
		return

	var health_bar: HealthBar = bars_by_target[target]

	if is_instance_valid(health_bar):
		health_bar.set_hp_ratio(hp_ratio)


func _on_target_destroyed(target: Target) -> void:
	if not bars_by_target.has(target):
		return

	var health_bar: HealthBar = bars_by_target[target]
	bars_by_target.erase(target)

	if is_instance_valid(health_bar):
		health_bar.queue_free()
