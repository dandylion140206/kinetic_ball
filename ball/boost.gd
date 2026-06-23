class_name Boost
extends Node


@export_range(0, 5000, 100) var impulse_power: int = 1800
@export_range(0.0, 2.0, 0.01) var cooldown: float = 0.5

@onready var cooldown_timer: Timer = $CooldownTimer

var _is_on_cooldown: bool = false


func _ready() -> void:
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)


func try_activate(boost_direction: Vector2) -> Vector2:
	if _is_on_cooldown:
		return Vector2.ZERO

	if boost_direction.length_squared() <= 0.0001:
		return Vector2.ZERO

	_is_on_cooldown = true
	cooldown_timer.start(cooldown)

	return boost_direction.normalized() * impulse_power


func is_on_cooldown() -> bool:
	return _is_on_cooldown


func _on_cooldown_timer_timeout() -> void:
	_is_on_cooldown = false
