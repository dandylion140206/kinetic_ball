class_name Boost
extends Node


@export_group("Time")
@export_range(0.0, 0.5, 0.01) var duration: float = 0.1
@export_range(0.0, 2.0, 0.02) var cooldown: float = 0.6

@export_group("Stat Modifier Boost")
@export_range(1.0, 3.0, 0.05) var target_speed_multiplier: float = 1.8
@export_range(1.0, 3.0, 0.05) var acceleration_multiplier: float = 1.8
@export_range(1.0, 3.0, 0.05) var max_speed_multiplier: float = 1.0

@onready var duration_timer: Timer = $DurationTimer
@onready var cooldown_timer: Timer = $CooldownTimer

var _is_active: bool = false
var _is_on_cooldown: bool = false


func _ready() -> void:
	duration_timer.one_shot = true
	cooldown_timer.one_shot = true

	duration_timer.timeout.connect(_on_duration_timer_timeout)
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)


func can_activate() -> bool:
	return not _is_on_cooldown


func is_active() -> bool:
	return _is_active


func is_on_cooldown() -> bool:
	return _is_on_cooldown


func try_activate() -> void:
	if not can_activate():
		return

	_is_active = true
	_is_on_cooldown = true

	duration_timer.start(duration)
	cooldown_timer.start(cooldown)


func get_target_speed_multiplier() -> float:
	if _is_active:
		return target_speed_multiplier

	return 1.0


func get_acceleration_multiplier() -> float:
	if _is_active:
		return acceleration_multiplier

	return 1.0


func get_max_speed_multiplier() -> float:
	if _is_active:
		return max_speed_multiplier

	return 1.0


func get_cooldown_left() -> float:
	return cooldown_timer.time_left


func get_duration_left() -> float:
	return duration_timer.time_left


func _on_duration_timer_timeout() -> void:
	_is_active = false


func _on_cooldown_timer_timeout() -> void:
	_is_on_cooldown = false
