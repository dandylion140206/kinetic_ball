class_name TargetVisual
extends Node2D

@export var radius: float = 40.0

@export var full_hp_color: Color = Color(0.2, 0.7, 1.0, 1.0)
@export var low_hp_color: Color = Color(1.0, 0.2, 0.2, 1.0)

var _hp_ratio: float = 1.0
var _overlay_color: Color = Color.WHITE
var _overlay_strength: float = 0.0


func _draw() -> void:
	var base_color := low_hp_color.lerp(full_hp_color, _hp_ratio)

	var display_color := base_color.lerp(
		_overlay_color,
		_overlay_strength
	)

	draw_circle(Vector2.ZERO, radius, display_color)


func set_hp_ratio(value: float) -> void:
	_hp_ratio = clampf(value, 0.0, 1.0)
	queue_redraw()


func set_overlay(color: Color, strength: float) -> void:
	_overlay_color = color
	_overlay_strength = clampf(strength, 0.0, 1.0)
	queue_redraw()


func clear_overlay() -> void:
	_overlay_strength = 0.0
	queue_redraw()
