class_name BoostController
extends Node

signal boost_activated(
	follow_node: Node2D,
	boost_direction: Vector2
)

@export var boost_path: NodePath = "Boost"
@export var motion_path: NodePath = "../BallMotion"
@export var follow_node_path: NodePath = ".."

@onready var boost: Boost = get_node_or_null(boost_path)
@onready var motion: BallMotion = get_node_or_null(motion_path)
@onready var follow_node: Node2D = get_node_or_null(follow_node_path)


func _ready() -> void:
	if boost == null:
		push_warning("BallBoostController: boost is not assigned.")

	if motion == null:
		push_warning("BallBoostController: motion is not assigned.")

	if follow_node == null:
		push_warning("BallBoostController: follow_node is not assigned.")


func try_activate() -> bool:
	if boost == null:
		return false

	if motion == null:
		return false

	var impulse := boost.try_activate(motion.get_velocity())

	if impulse.length_squared() <= 0.0001:
		return false

	motion.add_impulse(impulse)

	if follow_node != null:
		boost_activated.emit(
			follow_node,
			impulse.normalized()
		)

	return true
