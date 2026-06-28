class_name TargetDamageFeedback
extends Node

@export var visual_path: NodePath = "../TargetVisual"
@export var damage_flash_path: NodePath = "../DamageFlash"
@export var hit_sound_player_path: NodePath = "../HitSoundPlayer"

@onready var visual: TargetVisual = get_node_or_null(visual_path)
@onready var damage_flash: DamageFlash = get_node_or_null(damage_flash_path)
@onready var hit_sound_player: SoundPlayer = get_node_or_null(hit_sound_player_path)


func play_damage_feedback(hp_ratio: float) -> void:
	if visual != null:
		visual.set_hp_ratio(hp_ratio)

	if damage_flash != null:
		damage_flash.flash()


func play_hit_sound(global_position: Vector2) -> void:
	if hit_sound_player == null:
		return

	hit_sound_player.play_at(global_position)
