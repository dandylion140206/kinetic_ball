class_name DamageDealer
extends Node

signal damage_dealt(
	target: Node,
	attacker: Node,
	damage_info: Dictionary
)

@export_range(0, 5000, 100) var min_damage_speed: int = 500
@export_range(0, 100, 1) var base_damage: int = 0
@export_range(0.0, 0.1, 0.001) var speed_damage_scale: float = 0.018
@export_range(0, 9999, 1) var max_damage: int = 9999


func try_deal_damage(
	target: Node,
	attacker: Node,
	velocity: Vector2
) -> void:
	if target == null:
		return

	var speed := velocity.length()

	if speed < min_damage_speed:
		return

	var damage := _calculate_damage(speed)

	var damage_info := {
		"amount": damage,
		"speed": speed,
		"velocity": velocity,
		"direction": _get_direction_from_velocity(velocity),
		"attacker": attacker,
	}

	if target.has_method("take_damage"):
		target.take_damage(damage_info)
		damage_dealt.emit(
			target,
			attacker,
			damage_info
		)


func _calculate_damage(speed: float) -> float:
	var over_speed := speed - min_damage_speed

	var damage := base_damage + over_speed * speed_damage_scale

	return minf(damage, max_damage)


func _get_direction_from_velocity(velocity: Vector2) -> Vector2:
	if velocity.length_squared() <= 0.0001:
		return Vector2.ZERO

	return velocity.normalized()
