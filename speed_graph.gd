class_name SpeedGraph
extends Control

@export var max_samples := 240
@export var max_value := 6000.0
@export var line_color := Color.LIME

var current_value := 0.0
var values: Array[float] = []


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.5))

	if values.size() < 2:
		return

	for i in range(values.size() - 1):
		var x1 := float(i) / float(max_samples - 1) * size.x
		var x2 := float(i + 1) / float(max_samples - 1) * size.x

		var y1: float = size.y - clamp(values[i] / max_value, 0.0, 1.0) * size.y
		var y2: float = size.y - clamp(values[i + 1] / max_value, 0.0, 1.0) * size.y

		draw_line(
			Vector2(x1, y1),
			Vector2(x2, y2),
			line_color,
			2.0
		)

	var display_speed := int(current_value / 100.0) * 100

	draw_string(
		ThemeDB.fallback_font,
		Vector2(0, size.y + 20),
		"speed: %d" % display_speed,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color.WHITE
	)


func add_value(value: float) -> void:
	current_value = value

	values.append(value)

	if values.size() > max_samples:
		values.pop_front()

	queue_redraw()
