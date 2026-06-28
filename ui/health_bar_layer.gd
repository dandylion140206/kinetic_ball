class_name HealthBarLayer
extends Node2D

@export var health_bar_scene: PackedScene
@export var health_node_name: StringName = &"Health"

var bars_by_owner: Dictionary = {}


func register_health_owner(owner: Node2D) -> void:
	if owner == null:
		return

	if health_bar_scene == null:
		push_warning("HealthBarLayer: health_bar_scene is not assigned.")
		return

	if bars_by_owner.has(owner):
		return

	var health := owner.get_node_or_null(NodePath(health_node_name)) as Health

	if health == null:
		push_warning("HealthBarLayer: owner has no Health node: %s" % owner.name)
		return

	var health_bar := health_bar_scene.instantiate() as HealthBar

	if health_bar == null:
		push_warning("HealthBarLayer: health_bar_scene is not HealthBar.")
		return

	add_child(health_bar)

	health_bar.setup(owner, health.get_hp_ratio())
	bars_by_owner[owner] = health_bar

	health.damaged.connect(_on_health_damaged.bind(owner, health))
	health.died.connect(_on_health_died.bind(owner))


func unregister_health_owner(owner: Node2D) -> void:
	if owner == null:
		return

	if not bars_by_owner.has(owner):
		return

	var health_bar: HealthBar = bars_by_owner[owner]
	bars_by_owner.erase(owner)

	if is_instance_valid(health_bar):
		health_bar.queue_free()


func _on_health_damaged(
	_amount: float,
	_current_hp: float,
	_max_hp: float,
	owner: Node2D,
	health: Health
) -> void:
	if owner == null:
		return

	if health == null:
		return

	if not bars_by_owner.has(owner):
		return

	var health_bar: HealthBar = bars_by_owner[owner]

	if is_instance_valid(health_bar):
		health_bar.set_hp_ratio(health.get_hp_ratio())


func _on_health_died(owner: Node2D) -> void:
	unregister_health_owner(owner)
