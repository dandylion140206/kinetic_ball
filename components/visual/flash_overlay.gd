class_name FlashOverlay
extends Node

@export var overlay_target_path: NodePath
@export var flash_color: Color = Color.WHITE
@export_range(0.01, 0.5, 0.01) var duration: float = 0.2

var _tween: Tween

@onready var overlay_target: Node = get_node_or_null(overlay_target_path)


func flash() -> void:
	if overlay_target == null:
		return

	if not overlay_target.has_method("set_overlay"):
		push_warning("FlashOverlay: overlay_target must have set_overlay(color, strength).")
		return

	if _tween != null:
		_tween.kill()

	_set_flash_strength(1.0)

	_tween = create_tween()
	_tween.tween_method(
		_set_flash_strength,
		1.0,
		0.0,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _set_flash_strength(value: float) -> void:
	if overlay_target == null:
		return

	overlay_target.call(
		"set_overlay",
		flash_color,
		value
	)
