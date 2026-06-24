class_name TargetVisual
extends Node2D


@export var radius: float = 40.0

@export var full_hp_color: Color = Color(0.2, 0.7, 1.0, 1.0)
@export var low_hp_color: Color = Color(1.0, 0.2, 0.2, 1.0)

@export_group("Damage Highlight")
@export var hit_flash_color: Color = Color.WHITE
@export_range(0.01, 0.5, 0.01) var hit_flash_duration: float = 0.15

var _hp_ratio: float = 1.0
var _hit_flash_strength: float = 0.0
var _hit_flash_tween: Tween


func set_hp_ratio(value: float) -> void:
	_hp_ratio = clampf(value, 0.0, 1.0)
	queue_redraw()


func flash_damage() -> void:
	if _hit_flash_tween != null:
		_hit_flash_tween.kill()

	_set_hit_flash_strength(1.0)

	_hit_flash_tween = create_tween()
	_hit_flash_tween.tween_method(
		_set_hit_flash_strength,
		1.0,
		0.0,
		hit_flash_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _set_hit_flash_strength(value: float) -> void:
	_hit_flash_strength = clampf(value, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	var base_color := low_hp_color.lerp(full_hp_color, _hp_ratio)

	var display_color := base_color.lerp(
		hit_flash_color,
		_hit_flash_strength
	)

	draw_circle(Vector2.ZERO, radius, display_color)
