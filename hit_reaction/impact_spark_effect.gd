class_name ImpactSparkEffect
extends Node2D

@export_range(0.05, 1.0, 0.01) var lifetime_min: float = 0.12
@export_range(0.05, 1.0, 0.01) var lifetime_max: float = 0.24
@export_range(4, 80, 1) var amount_min: int = 8
@export_range(4, 120, 1) var amount_max: int = 28
@export_range(50.0, 1000.0, 10.0) var velocity_min: float = 180.0
@export_range(50.0, 1500.0, 10.0) var velocity_max: float = 520.0
@export_range(0.0, 1.0, 0.05) var auto_free_padding: float = 0.2

@onready var particles: CPUParticles2D = $Particles


func _ready() -> void:
	particles.emitting = false
	particles.one_shot = true
	particles.local_coords = false
	particles.gravity = Vector2.ZERO


func play(
	spawn_position: Vector2,
	direction: Vector2,
	strength_ratio: float
) -> void:
	if direction.length_squared() <= 0.0001:
		queue_free()
		return

	strength_ratio = clampf(strength_ratio, 0.0, 1.0)

	global_position = spawn_position
	global_rotation = direction.normalized().angle()

	_configure_particles(strength_ratio)

	particles.restart()
	particles.emitting = true

	await get_tree().create_timer(
		particles.lifetime + auto_free_padding
	).timeout

	queue_free()


func _configure_particles(strength_ratio: float) -> void:
	particles.amount = int(
		lerpf(
			float(amount_min),
			float(amount_max),
			strength_ratio
		)
	)

	particles.lifetime = lerpf(
		lifetime_min,
		lifetime_max,
		strength_ratio
	)

	particles.initial_velocity_min = lerpf(
		velocity_min,
		velocity_max * 0.65,
		strength_ratio
	)

	particles.initial_velocity_max = lerpf(
		velocity_min * 1.2,
		velocity_max,
		strength_ratio
	)

	particles.direction = Vector2.RIGHT
