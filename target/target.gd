class_name Target
extends Node2D

signal destroyed(target: Target)

@onready var collision_shape: CollisionShape2D = $HitArea/CollisionShape2D
@onready var visual: TargetVisual = $TargetVisual
@onready var health: Health = $Health
@onready var damage_receiver: DamageReceiver = $DamageReceiver
@onready var damage_feedback: TargetDamageFeedback = $TargetDamageFeedback
@onready var death_handler: TargetDeathHandler = $TargetDeathHandler
@onready var hit_stop: HitStopReceiver = $HitStopReceiver


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


func request_hit_stop(duration: float) -> void:
	if hit_stop == null:
		return

	hit_stop.request_hit_stop(duration)


func _on_damage_received(damage_info: DamageInfo) -> void:
	if damage_info == null:
		return

	if damage_info.amount <= 0.0:
		return

	health.apply_damage(damage_info.amount)


func _on_health_damaged(
	_amount: float,
	current_hp: float,
	_max_hp: float
) -> void:
	var hp_ratio := health.get_hp_ratio()

	damage_feedback.play_damage_feedback(hp_ratio)

	if current_hp > 0.0:
		damage_feedback.play_hit_sound(global_position)


func _on_health_died() -> void:
	death_handler.handle_death(self)

	destroyed.emit(self)

	queue_free()
