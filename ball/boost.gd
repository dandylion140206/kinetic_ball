class_name Boost
extends Node

@export_range(0, 5000, 100) var impulse_power: int = 1400
@export_range(0.0, 2.0, 0.02) var cooldown: float = 0.4
@export var sound_origin_path: NodePath = "../.."

var _is_on_cooldown: bool = false

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var boost_sound_player: OneShotSoundPlayer2D = $BoostSoundPlayer
@onready var sound_origin: Node2D = get_node_or_null(sound_origin_path)


func _ready() -> void:
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)

	if sound_origin == null:
		push_warning("Boost: sound_origin is not assigned.")


func try_activate(current_velocity: Vector2) -> Vector2:
	if _is_on_cooldown:
		return Vector2.ZERO

	var boost_direction := _calculate_boost_direction(current_velocity)

	if boost_direction.length_squared() <= 0.0001:
		return Vector2.ZERO

	_is_on_cooldown = true
	cooldown_timer.start(cooldown)

	if boost_sound_player != null:
		boost_sound_player.play_at(_get_sound_position())

	return boost_direction * impulse_power


func is_on_cooldown() -> bool:
	return _is_on_cooldown


func _calculate_boost_direction(current_velocity: Vector2) -> Vector2:
	if current_velocity.length_squared() <= 0.0001:
		return Vector2.ZERO

	return current_velocity.normalized()


func _get_sound_position() -> Vector2:
	if sound_origin == null:
		return Vector2.ZERO

	return sound_origin.global_position


func _on_cooldown_timer_timeout() -> void:
	_is_on_cooldown = false
