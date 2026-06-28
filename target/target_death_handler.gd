class_name TargetDeathHandler
extends Node

@export var hit_area_path: NodePath = "../HitArea"
@export var collision_shape_path: NodePath = "../HitArea/CollisionShape2D"
@export var destroy_sound_player_path: NodePath = "../DestroySoundPlayer"

@onready var hit_area: Area2D = get_node_or_null(hit_area_path)
@onready var collision_shape: CollisionShape2D = get_node_or_null(collision_shape_path)
@onready var destroy_sound_player: OneShotSoundPlayer2D = get_node_or_null(destroy_sound_player_path)


func handle_death(target: Node2D) -> void:
	var death_position := Vector2.ZERO

	if target != null:
		death_position = target.global_position

	if destroy_sound_player != null:
		destroy_sound_player.play_at(death_position)

	if hit_area != null:
		hit_area.monitoring = false
		hit_area.monitorable = false

	if collision_shape != null:
		collision_shape.disabled = true

	if target != null:
		target.visible = false
