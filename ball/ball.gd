extends Area2D

signal speed_updated(speed: float)

@onready var movement: BallMovement = $BallMovement

var velocity: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	velocity = movement.update_velocity(
		global_position,
		get_global_mouse_position(),
		delta
	)

	global_position += velocity * delta

	speed_updated.emit(velocity.length())
