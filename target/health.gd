class_name Health
extends Node


signal damaged(amount: float, current_hp: float, max_hp: float)
signal died

@export_range(1.0, 1000.0, 1.0) var max_hp: float = 100.0

var current_hp: float


func _ready() -> void:
	current_hp = max_hp


func apply_damage(amount: float) -> void:
	if amount <= 0.0:
		return

	current_hp = maxf(current_hp - amount, 0.0)

	damaged.emit(amount, current_hp, max_hp)

	if current_hp <= 0.0:
		died.emit()


func get_hp_ratio() -> float:
	if max_hp <= 0.0:
		return 0.0

	return current_hp / max_hp
