class_name Target
extends Node2D

signal destroyed(target: Target)

@onready var collision_shape: CollisionShape2D = $HitArea/CollisionShape2D
@onready var visual: TargetVisual = $TargetVisual
@onready var health: Health = $Health
@onready var damage_flash: DamageFlash = $DamageFlash
@onready var hit_sound_player: = HitSoundPlayer = $HitSoundPlayer
@onready var damage_receiver: DamageReceiver = $DamageReceiver
@onready var damage_feedback: TargetDamageFeedback = $TargetDamageFeedback
@onready var death_handler: TargetDeathHandler = $TargetDeathHandler


func _ready() -> void:
	damage_receiver.damage_received.connect(_on_damage_received)
	health.damaged.connect(_on_health_damaged)
	health.died.connect(_on_health_died)


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


func _on_damage_received(damage_info: DamageInfo) -> void:
	if damage_info == null:
		return

	if damage_info.amount <= 0.0:
		return

	health.apply_damage(damage_info.amount)


func _on_health_damaged(
	amount: float,
	current_hp: float,
	max_hp: float
) -> void:
	var hp_ratio := health.get_hp_ratio()

	visual.set_hp_ratio(hp_ratio)
	damage_flash.flash()

	if current_hp > 0.0:
		hit_sound_player.play_at(global_position)


func _on_health_died() -> void:
	death_handler.handle_death(self)

	destroyed.emit(self)

	queue_free()
