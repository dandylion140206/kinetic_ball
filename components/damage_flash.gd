class_name DamageFlash
extends Node

@export var visual_path: NodePath
@export var flash_color: Color = Color.WHITE
@export_range(0.01, 0.5, 0.01) var duration: float = 0.15

var _tween: Tween

@onready var visual: TargetVisual = get_node_or_null(visual_path)


func flash() -> void:
	if visual == null:
		return

	if _tween != null:
		_tween.kill()

	visual.set_overlay(flash_color, 1.0)

	_tween = create_tween()
	_tween.tween_method(
		_set_flash_strength,
		1.0,
		0.0,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _set_flash_strength(value: float) -> void:
	if visual == null:
		return

	visual.set_overlay(flash_color, value)
