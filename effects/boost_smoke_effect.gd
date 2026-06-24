class_name BoostSmokeEffect
extends Node2D

@export_range(0.0, 100.0, 1.0) var spawn_back_offset: float = 25.0
@export_range(0.0, 2.0, 0.05) var auto_free_padding: float = 0.3

@export_group("Generated Circle Texture")
@export var use_generated_circle_texture: bool = true
@export_range(8, 128, 1) var circle_texture_size: int = 48

@onready var particles: CPUParticles2D = $Particles


func _ready() -> void:
	if use_generated_circle_texture and particles.texture == null:
		particles.texture = _create_circle_texture(circle_texture_size)


func play(
	ball_global_position: Vector2,
	boost_direction: Vector2
) -> void:
	if boost_direction.length_squared() <= 0.0001:
		queue_free()
		return

	var normalized_boost_direction := boost_direction.normalized()
	var smoke_direction := -normalized_boost_direction

	global_position = ball_global_position + smoke_direction * spawn_back_offset
	global_rotation = smoke_direction.angle()

	particles.emitting = false
	particles.restart()
	particles.emitting = true

	_auto_free()


func _auto_free() -> void:
	var wait_time := particles.lifetime + auto_free_padding
	await get_tree().create_timer(wait_time).timeout
	queue_free()


func _create_circle_texture(size: int) -> Texture2D:
	var image := Image.create_empty(
		size,
		size,
		false,
		Image.FORMAT_RGBA8
	)

	var center := Vector2(size * 0.5, size * 0.5)
	var radius := size * 0.42
	var edge_softness := 3.0

	for y in range(size):
		for x in range(size):
			var pos := Vector2(x, y)
			var distance := pos.distance_to(center)

			var alpha := clampf(
				(radius - distance) / edge_softness,
				0.0,
				1.0
			)

			image.set_pixel(
				x,
				y,
				Color(1.0, 1.0, 1.0, alpha)
			)

	var texture := ImageTexture.create_from_image(image)

	return texture
