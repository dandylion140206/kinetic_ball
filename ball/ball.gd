extends Area2D


# デバッグ用
signal speed_updated(speed: float)

@export var movement_stats: MovementStats

@onready var movement: Movement = $Movement
@onready var boost: Boost = $Boost

var velocity: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	var target_position := get_global_mouse_position()
	var cursor_direction := _get_cursor_direction(target_position)

	if Input.is_action_just_pressed("primary_action"):
		var impulse := boost.try_activate(velocity)

		velocity += impulse

	velocity = movement.calculate_velocity(
		velocity,
		global_position,
		target_position,
		movement_stats,
		delta
	)

	global_position += velocity * delta

	# デバッグ用
	speed_updated.emit(velocity.length())


func _get_cursor_direction(target_position: Vector2) -> Vector2:
	var to_target := target_position - global_position

	if to_target.length_squared() <= 0.0001:
		return Vector2.ZERO

	return to_target.normalized()
