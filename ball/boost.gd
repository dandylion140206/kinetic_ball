class_name Boost
extends Node


@export_group("Impulse Boost")
@export_range(0, 5000, 100) var impulse_power: int = 2000

@export_group("Cooldown")
@export_range(0.0, 2.0, 0.02) var cooldown: float = 0.4

@onready var cooldown_timer: Timer = $CooldownTimer

var _is_on_cooldown: bool = false


func _ready() -> void:
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)


func try_activate(current_velocity: Vector2) -> Vector2:
	if _is_on_cooldown:
		return Vector2.ZERO

	var boost_direction := _calculate_boost_direction(current_velocity)

	if boost_direction.length_squared() <= 0.0001:
		return Vector2.ZERO

	_is_on_cooldown = true
	cooldown_timer.start(cooldown)

	return boost_direction * impulse_power


func is_on_cooldown() -> bool:
	return _is_on_cooldown


func _calculate_boost_direction(current_velocity: Vector2) -> Vector2:
	if current_velocity.length_squared() <= 0.0001:
		return Vector2.ZERO

	return current_velocity.normalized()


func _on_cooldown_timer_timeout() -> void:
	_is_on_cooldown = false
