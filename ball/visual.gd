class_name Visual
extends Node2D


@export var radius: float = 20.0

@export var color: Color = Color(0.9, 0.9, 0.9, 1.0)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)
