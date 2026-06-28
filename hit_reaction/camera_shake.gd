class_name CameraShake
extends Node

@export var camera_path: NodePath = ".."

@export var make_current_on_ready: bool = true
@export var center_camera_on_ready: bool = true

@export_range(0.0, 30.0, 0.5) var min_power: float = 1.0
@export_range(0.0, 50.0, 0.5) var max_power: float = 6.0
@export_range(0.01, 0.5, 0.01) var min_duration: float = 0.04
@export_range(0.01, 0.5, 0.01) var max_duration: float = 0.10
@export_range(0.5, 5.0, 0.1) var decay_power: float = 2.0

var _shake_start_msec: int = 0
var _shake_end_msec: int = 0
var _shake_duration_msec: int = 1
var _shake_power: float = 0.0
var _shake_direction: Vector2 = Vector2.RIGHT
var _base_offset: Vector2 = Vector2.ZERO
var _frame_index: int = 0

@onready var camera: Camera2D = get_node_or_null(camera_path)


func _ready() -> void:
	if camera == null:
		push_warning("CameraShake: camera is not assigned.")
		set_process(false)
		return

	if make_current_on_ready:
		camera.enabled = true
		camera.make_current()

	if center_camera_on_ready:
		var viewport_rect := get_viewport().get_visible_rect()
		camera.global_position = viewport_rect.position + viewport_rect.size * 0.5

	_base_offset = camera.offset

	set_process(false)


func _process(_delta: float) -> void:
	if camera == null:
		set_process(false)
		return

	if not _is_shaking():
		camera.offset = _base_offset
		set_process(false)
		return

	_apply_shake()


func request_shake(
	strength_ratio: float,
	direction: Vector2
) -> void:
	if camera == null:
		return

	strength_ratio = clampf(strength_ratio, 0.0, 1.0)

	var now := Time.get_ticks_msec()
	var was_shaking := _is_shaking_at(now)

	var duration := lerpf(
		min_duration,
		max_duration,
		strength_ratio
	)

	var new_end_msec := now + int(duration * 1000.0)
	var new_power := lerpf(
		min_power,
		max_power,
		strength_ratio
	)

	var current_power := _get_current_power(now)

	_shake_end_msec = maxi(
		_shake_end_msec,
		new_end_msec
	)

	if not was_shaking or new_power >= current_power:
		_shake_start_msec = now
		_shake_duration_msec = maxi(
			1,
			int(duration * 1000.0)
		)
		_shake_power = new_power
		_shake_direction = _get_valid_direction(direction)
		_frame_index = 0

	set_process(true)


func _apply_shake() -> void:
	var now := Time.get_ticks_msec()
	var current_power := _get_current_power(now)

	var main_sign := 1.0

	if _frame_index % 2 == 1:
		main_sign = -1.0

	var perpendicular_sign := 1.0
	var perpendicular_phase := floori(float(_frame_index) / 2.0)

	if perpendicular_phase % 2 == 1:
		perpendicular_sign = -1.0

	var perpendicular := Vector2(
		-_shake_direction.y,
		_shake_direction.x
	)

	var shake_offset := _shake_direction * main_sign * current_power
	shake_offset += perpendicular * perpendicular_sign * current_power * 0.5

	camera.offset = _base_offset + shake_offset

	_frame_index += 1


func _get_current_power(now: int) -> float:
	if not _is_shaking_at(now):
		return 0.0

	var elapsed := now - _shake_start_msec
	var progress := float(elapsed) / float(_shake_duration_msec)
	progress = clampf(progress, 0.0, 1.0)

	var remaining := 1.0 - progress

	return _shake_power * pow(remaining, decay_power)


func _is_shaking() -> bool:
	return _is_shaking_at(Time.get_ticks_msec())


func _is_shaking_at(now: int) -> bool:
	return now < _shake_end_msec


func _get_valid_direction(direction: Vector2) -> Vector2:
	if direction.length_squared() <= 0.0001:
		return Vector2.RIGHT

	return direction.normalized()
