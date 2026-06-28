class_name DamageInfo
extends RefCounted

var amount: float
var speed: float
var velocity: Vector2
var direction: Vector2
var attacker: Node


func _init(
	amount_value: float = 0.0,
	speed_value: float = 0.0,
	velocity_value: Vector2 = Vector2.ZERO,
	direction_value: Vector2 = Vector2.ZERO,
	attacker_value: Node = null
) -> void:
	amount = amount_value
	speed = speed_value
	velocity = velocity_value
	direction = direction_value
	attacker = attacker_value
