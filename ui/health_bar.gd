class_name HealthBar
extends Node2D

@export_range(10.0, 200.0, 1.0) var bar_width: float = 50.0
@export_range(2.0, 30.0, 1.0) var bar_height: float = 6.0
@export var offset: Vector2 = Vector2(0, -52)

@export var background_color: Color = Color(0.0, 0.0, 0.0, 0.6)
@export var hp_color: Color = Color(0.2, 1.0, 0.3, 1.0)
@export var border_color: Color = Color.WHITE

var hp_ratio: float = 1.0
var follow_target: Node2D


func _ready() -> void:
	z_index = 100
	z_as_relative = false
	visible = false


func _process(delta: float) -> void:
	if follow_target == null or not is_instance_valid(follow_target):
		queue_free()
		return

	global_position = follow_target.global_position + offset


func _draw() -> void:
	if not visible:
		return

	var top_left := Vector2(-bar_width * 0.5, -bar_height * 0.5)

	draw_rect(
		Rect2(top_left, Vector2(bar_width, bar_height)),
		background_color,
		true
	)

	draw_rect(
		Rect2(top_left, Vector2(bar_width * hp_ratio, bar_height)),
		hp_color,
		true
	)

	draw_rect(
		Rect2(top_left, Vector2(bar_width, bar_height)),
		border_color,
		false,
		1.0
	)


func setup(target: Node2D, initial_hp_ratio: float) -> void:
	follow_target = target
	set_hp_ratio(initial_hp_ratio)

	if follow_target != null:
		global_position = follow_target.global_position + offset


func set_hp_ratio(value: float) -> void:
	hp_ratio = clampf(value, 0.0, 1.0)
	visible = hp_ratio < 1.0
	queue_redraw()
