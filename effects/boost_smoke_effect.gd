class_name BoostSmokeEffect
extends Node2D

@export_range(0.0, 1000.0, 1.0) var spawn_back_offset: float = 20.0
@export_range(0.05, 0.5, 0.01) var emission_duration: float = 0.34
@export_range(0.0, 2.0, 0.05) var auto_free_padding: float = 0.3

@export_group("Generated Circle Texture")
@export var use_generated_circle_texture: bool = true
@export_range(8, 128, 1) var circle_texture_size: int = 52

@onready var particles: CPUParticles2D = $Particles

var _follow_node: Node2D
var _smoke_direction: Vector2 = Vector2.LEFT
var _is_following: bool = false


func _ready() -> void:
	if use_generated_circle_texture and particles.texture == null:
		particles.texture = _create_circle_texture(circle_texture_size)

	# ここでは最低限だけ設定する
	particles.gravity = Vector2.ZERO
	particles.local_coords = false


func play(
	follow_node: Node2D,
	boost_direction: Vector2
) -> void:
	if follow_node == null:
		queue_free()
		return

	if boost_direction.length_squared() <= 0.0001:
		queue_free()
		return

	_follow_node = follow_node
	_smoke_direction = -boost_direction.normalized()
	_is_following = true

	_update_emitter_position()

	particles.emitting = false
	particles.restart()
	particles.emitting = true

	set_process(true)

	_stop_emission_later()


func _process(_delta: float) -> void:
	if not _is_following:
		return

	if not is_instance_valid(_follow_node):
		_stop_emission()
		return

	_update_emitter_position()


func _update_emitter_position() -> void:
	global_position = _follow_node.global_position + _smoke_direction * spawn_back_offset
	global_rotation = _smoke_direction.angle()


func _stop_emission_later() -> void:
	await get_tree().create_timer(emission_duration).timeout
	_stop_emission()

	await get_tree().create_timer(particles.lifetime + auto_free_padding).timeout
	queue_free()


func _stop_emission() -> void:
	_is_following = false
	particles.emitting = false
	set_process(false)


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
