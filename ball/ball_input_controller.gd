class_name BallInputController
extends Node

@export var boost_action: StringName = &"primary_action"


func get_movement_target(reference_node: Node2D) -> Vector2:
	if reference_node == null:
		return Vector2.ZERO

	return reference_node.get_global_mouse_position()


func is_boost_requested() -> bool:
	return Input.is_action_just_pressed(boost_action)
