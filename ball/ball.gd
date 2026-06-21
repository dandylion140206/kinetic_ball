extends Area2D

signal speed_updated(speed: float)

@export var movement_stats: MovementStats

@onready var movement: Movement = $Movement
@onready var boost: Boost = $Boost

var velocity: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	var target_position := get_global_mouse_position()

	if Input.is_action_just_pressed("primary_action"):
		boost.try_activate()


	velocity = movement.calculate_velocity(
		velocity,
		global_position,
		target_position,
		movement_stats,
		delta,
		boost.get_target_speed_multiplier(),
		boost.get_acceleration_multiplier(),
		boost.get_max_speed_multiplier()
	)

	global_position += velocity * delta

	speed_updated.emit(velocity.length())
