extends Area2D

# デバッグ用
signal speed_updated(speed: float, is_boost_active: bool)

@export var movement_stats: MovementStats

@onready var movement: Movement = $Movement
@onready var boost: Boost = $Boost
@onready var visual: Visual = $Visual

var velocity: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	var target_position := get_global_mouse_position()

	boost.update_input(
		Input.is_action_pressed("primary_action"),
		Input.is_action_just_pressed("primary_action"),
		velocity
	)

	visual.set_boost_active(boost.is_active())

	velocity = movement.calculate_velocity(
		velocity,
		global_position,
		target_position,
		movement_stats,
		delta
	)

	var final_velocity := boost.apply_velocity_boost(velocity)

	global_position += final_velocity * delta

	# デバッグ用
	speed_updated.emit(final_velocity.length(), boost.is_active())
