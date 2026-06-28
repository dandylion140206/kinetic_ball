class_name DamageReceiver
extends Node

signal damage_received(damage_info: DamageInfo)


func receive_damage(damage_info: DamageInfo) -> void:
	if damage_info == null:
		return

	damage_received.emit(damage_info)


func get_damage_target() -> Node:
	var parent := get_parent()

	if parent == null:
		return self

	return parent
