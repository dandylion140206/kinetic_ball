class_name Target
extends Node2D

signal destroyed(target: Target)
signal health_ratio_changed(target: Target, hp_ratio: float)

@onready var hit_area: Area2D = $HitArea
@onready var collision_shape: CollisionShape2D = $HitArea/CollisionShape2D
@onready var visual: TargetVisual = $TargetVisual
@onready var damage_flash: DamageFlash = $DamageFlash
@onready var health: Health = $Health
@onready var hit_sound_player: SoundPlayer = $HitSoundPlayer
@onready var destroy_sound_player: SoundPlayer = $DestroySoundPlayer


func _ready() -> void:
	health.damaged.connect(_on_health_damaged)
	health.died.connect(_on_health_died)

	health_ratio_changed.emit(self, health.get_hp_ratio())


func take_damage(damage_info: Dictionary) -> void:
	var amount := _get_damage_amount(damage_info)

	if amount <= 0.0:
		return

	health.apply_damage(amount)


func get_target_radius() -> float:
	return get_collision_radius()


func get_collision_radius() -> float:
	if collision_shape != null:
		var shape := collision_shape.shape

		if shape is CircleShape2D:
			var circle := shape as CircleShape2D
			return circle.radius * global_scale.x

	return visual.radius * global_scale.x


func get_hp_ratio() -> float:
	return health.get_hp_ratio()


func _get_damage_amount(damage_info: Dictionary) -> float:
	if not damage_info.has("amount"):
		return 0.0

	return float(damage_info["amount"])


func _on_health_damaged(
	amount: float,
	current_hp: float,
	max_hp: float
) -> void:
	var hp_ratio := health.get_hp_ratio()

	visual.set_hp_ratio(hp_ratio)
	damage_flash.flash()

	health_ratio_changed.emit(self, hp_ratio)

	if current_hp > 0.0:
		hit_sound_player.play_at(global_position)


func _on_health_died() -> void:
	destroy_sound_player.play_at(global_position)

	hit_area.monitoring = false
	hit_area.monitorable = false
	collision_shape.disabled = true
	visible = false

	destroyed.emit(self)

	queue_free()
