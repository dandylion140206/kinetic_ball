class_name HitReactionDirector
extends Node

@export_range(0.0, 10000.0, 100.0) var min_speed: float = 500.0
@export_range(0.0, 20000.0, 100.0) var max_speed: float = 7000.0
@export_range(0.0, 0.1, 0.002) var min_duration: float = 0.01
@export_range(0.0, 0.1, 0.002) var max_duration: float = 0.034
@export_range(0.0, 2.0, 0.05) var attacker_duration_multiplier: float = 1.0
@export_range(0.0, 2.0, 0.05) var target_duration_multiplier: float = 1.0


func play_hit_reaction(
	target: Node,
	attacker: Node,
	damage_info: Dictionary
) -> void:
	if target == null or attacker == null:
		return

	var speed := _get_speed(damage_info)
	var strength_ratio := _get_strength_ratio(speed)

	var duration := lerpf(
		min_duration,
		max_duration,
		strength_ratio
	)

	_request_hit_stop(
		attacker,
		duration * attacker_duration_multiplier
	)

	_request_hit_stop(
		target,
		duration * target_duration_multiplier
	)


func _request_hit_stop(
	node: Node,
	duration: float
) -> void:
	var receiver := _find_hit_stop_receiver(node)

	if receiver == null:
		return

	receiver.request_hit_stop(duration)


func _find_hit_stop_receiver(node: Node) -> HitStopReceiver:
	var direct_receiver := node.get_node_or_null("HitStopReceiver") as HitStopReceiver

	if direct_receiver != null:
		return direct_receiver

	for child in node.get_children():
		if child is HitStopReceiver:
			return child

	return null


func _get_speed(damage_info: Dictionary) -> float:
	if not damage_info.has("speed"):
		return 0.0

	return float(damage_info["speed"])


func _get_strength_ratio(speed: float) -> float:
	var ratio := inverse_lerp(
		min_speed,
		max_speed,
		speed
	)

	return clampf(ratio, 0.0, 1.0)
