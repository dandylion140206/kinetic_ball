class_name HealthBar
extends Node2D


@export var bar_width: float = 55.0
@export var bar_height: float = 6.0

@export var background_color: Color = Color(0.0, 0.0, 0.0, 0.7)
@export var hp_color: Color = Color(0.2, 1.0, 0.2, 1.0)
@export var border_color: Color = Color(1.0, 1.0, 1.0, 0.8)

var _hp_ratio: float = 1.0


func _ready() -> void:
	_update_visibility()


func set_hp_ratio(value: float) -> void:
	_hp_ratio = clampf(value, 0.0, 1.0)
	_update_visibility()
	queue_redraw()


func _update_visibility() -> void:
	visible = _hp_ratio < 1.0


func _draw() -> void:
	if _hp_ratio >= 1.0:
		return

	var top_left := Vector2(
		-bar_width * 0.5,
		-bar_height * 0.5
	)

	var background_rect := Rect2(
		top_left,
		Vector2(bar_width, bar_height)
	)

	var hp_rect := Rect2(
		top_left,
		Vector2(bar_width * _hp_ratio, bar_height)
	)

	draw_rect(background_rect, background_color, true)
	draw_rect(hp_rect, hp_color, true)
	draw_rect(background_rect, border_color, false, 1.0)
