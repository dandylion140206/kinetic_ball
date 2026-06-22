class_name Boost
extends Node


enum ActivationMode {
	TIMED,
	HOLD,
	IMPACT,
}


@export var activation_mode: ActivationMode = ActivationMode.IMPACT

@export_group("Velocity Boost")
@export_range(1.0, 3.0, 0.05) var velocity_multiplier: float = 1.2
@export_range(0.0, 10000, 100) var bonus_speed: int = 1500
@export_range(0.1, 4.0, 0.1) var timed_fade_power: float = 1.0

@export_group("Timed / Impact")
@export_range(0.0, 0.5, 0.01) var duration: float = 0.12
@export_range(0.0, 2.0, 0.02) var cooldown: float = 0.4

@onready var duration_timer: Timer = $DurationTimer
@onready var cooldown_timer: Timer = $CooldownTimer

var _is_active: bool = false
var _is_on_cooldown: bool = false
var _locked_boost_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	duration_timer.one_shot = true
	cooldown_timer.one_shot = true

	duration_timer.timeout.connect(_on_duration_timer_timeout)
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)


func update_input(
	is_pressed: bool,
	is_just_pressed: bool,
	current_velocity: Vector2
) -> void:
	match activation_mode:
		ActivationMode.HOLD:
			_is_active = is_pressed
			_is_on_cooldown = false

			if is_pressed:
				_locked_boost_direction = _get_direction_from_velocity(current_velocity)

		ActivationMode.TIMED:
			if is_just_pressed:
				_try_activate_timed(current_velocity)

		ActivationMode.IMPACT:
			if is_just_pressed:
				_try_activate_impact(current_velocity)


func apply_velocity_boost(base_velocity: Vector2) -> Vector2:
	var strength := _get_boost_strength()

	if strength <= 0.0:
		return base_velocity

	match activation_mode:
		ActivationMode.HOLD:
			return _apply_follow_velocity_boost(base_velocity, strength)

		ActivationMode.TIMED:
			return _apply_follow_velocity_boost(base_velocity, strength)

		ActivationMode.IMPACT:
			return _apply_locked_direction_boost(base_velocity, strength)

	return base_velocity


func is_active() -> bool:
	return _is_active


func is_on_cooldown() -> bool:
	return _is_on_cooldown


func _try_activate_timed(current_velocity: Vector2) -> void:
	if _is_on_cooldown:
		return

	_is_active = true
	_is_on_cooldown = true
	_locked_boost_direction = _get_direction_from_velocity(current_velocity)

	duration_timer.start(duration)
	cooldown_timer.start(cooldown)


func _try_activate_impact(current_velocity: Vector2) -> void:
	if _is_on_cooldown:
		return

	_is_active = true
	_is_on_cooldown = true
	_locked_boost_direction = _get_direction_from_velocity(current_velocity)

	duration_timer.start(duration)
	cooldown_timer.start(cooldown)


func _apply_follow_velocity_boost(base_velocity: Vector2, strength: float) -> Vector2:
	var multiplier := lerpf(1.0, velocity_multiplier, strength)
	var final_velocity := base_velocity * multiplier

	if base_velocity.length_squared() > 0.0001:
		final_velocity += base_velocity.normalized() * bonus_speed * strength

	return final_velocity


func _apply_locked_direction_boost(base_velocity: Vector2, strength: float) -> Vector2:
	var multiplier := lerpf(1.0, velocity_multiplier, strength)
	var final_velocity := base_velocity * multiplier

	if _locked_boost_direction.length_squared() > 0.0001:
		final_velocity += _locked_boost_direction * bonus_speed * strength

	return final_velocity


func _get_boost_strength() -> float:
	if not _is_active:
		return 0.0

	match activation_mode:
		ActivationMode.HOLD:
			return 1.0

		ActivationMode.TIMED:
			return _get_timed_fade_ratio()

		ActivationMode.IMPACT:
			return _get_timed_fade_ratio()

	return 0.0


func _get_timed_fade_ratio() -> float:
	if duration <= 0.0:
		return 0.0

	var remaining_ratio := duration_timer.time_left / duration
	remaining_ratio = clampf(remaining_ratio, 0.0, 1.0)

	return pow(remaining_ratio, timed_fade_power)


func _get_direction_from_velocity(current_velocity: Vector2) -> Vector2:
	if current_velocity.length_squared() <= 0.0001:
		return Vector2.ZERO

	return current_velocity.normalized()


func _on_duration_timer_timeout() -> void:
	_is_active = false
	_locked_boost_direction = Vector2.ZERO


func _on_cooldown_timer_timeout() -> void:
	_is_on_cooldown = false
