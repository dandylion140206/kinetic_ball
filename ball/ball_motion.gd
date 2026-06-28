class_name BallMotion
extends Node

@export var body_path: NodePath = ".."

var velocity: Vector2 = Vector2.ZERO

@onready var body: Node2D = get_node_or_null(body_path)


func _ready() -> void:
	if body == null:
		push_warning("BallMotion: body is not assigned.")


func set_velocity(value: Vector2) -> void:
	velocity = value


func add_impulse(impulse: Vector2) -> void:
	velocity += impulse


func move(delta: float) -> void:
	if body == null:
		return

	body.global_position += velocity * delta


func get_velocity() -> Vector2:
	return velocity


func get_speed() -> float:
	return velocity.length()


func get_velocity_direction() -> Vector2:
	if velocity.length_squared() <= 0.0001:
		return Vector2.ZERO

	return velocity.normalized()
