class_name Visual
extends Node2D

@export var radius: float = 20.0

@export var normal_color: Color = Color(0.9, 0.9, 0.9, 1.0)
@export var boost_color: Color = Color(0.3, 1.0, 0.3, 1.0)

var _current_color: Color


func _ready() -> void:
	_current_color = normal_color


func set_boost_active(is_boost_active: bool) -> void:
	var next_color := boost_color if is_boost_active else normal_color

	if _current_color == next_color:
		return

	_current_color = next_color
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, _current_color)
