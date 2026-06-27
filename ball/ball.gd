class_name Ball
extends Node2D

signal speed_updated(speed: float)

signal boost_activated(
	follow_node: Node2D,
	boost_direction: Vector2
)

signal hit_confirmed(
	target: Node,
	attacker: Node,
	damage_info: Dictionary
)

@export var movement_stats: MovementStats

var velocity: Vector2 = Vector2.ZERO
var previous_global_position: Vector2 = Vector2.ZERO

var _last_motion_from: Vector2 = Vector2.ZERO
var _last_motion_to: Vector2 = Vector2.ZERO

@onready var hit_area: Area2D = $HitArea
@onready var collision_shape: CollisionShape2D = $HitArea/CollisionShape2D
@onready var movement: Movement = $Movement
@onready var boost: Boost = $Boost
@onready var damage_dealer: DamageDealer = $DamageDealer
@onready var hit_stop: HitStopReceiver = $HitStopReceiver


func _ready() -> void:
	previous_global_position = global_position
	_last_motion_from = global_position
	_last_motion_to = global_position

	hit_area.area_entered.connect(_on_area_entered)
	hit_area.body_entered.connect(_on_body_entered)
	damage_dealer.damage_dealt.connect(_on_damage_dealt)


func _process(delta: float) -> void:
	if hit_stop.is_hit_stopped():
		if _try_cancel_hit_stop_with_boost(delta):
			return

		speed_updated.emit(velocity.length())
		return

	_process_normal_movement(delta)


func get_velocity_direction() -> Vector2:
	if velocity.length_squared() <= 0.0001:
		return Vector2.ZERO

	return velocity.normalized()


func get_collision_radius() -> float:
	if collision_shape == null:
		return 0.0

	var shape := collision_shape.shape

	if shape is CircleShape2D:
		var circle := shape as CircleShape2D
		return circle.radius * global_scale.x

	return 0.0


func _process_normal_movement(delta: float) -> void:
	var target_position := get_global_mouse_position()

	velocity = movement.calculate_velocity(
		velocity,
		global_position,
		target_position,
		movement_stats,
		delta
	)

	if Input.is_action_just_pressed("primary_action"):
		_try_activate_boost()

	_move_by_velocity(delta)

	speed_updated.emit(velocity.length())


func _try_cancel_hit_stop_with_boost(delta: float) -> bool:
	if not Input.is_action_just_pressed("primary_action"):
		return false

	if not _try_activate_boost():
		return false

	hit_stop.clear_hit_stop()

	_move_by_velocity(delta)

	speed_updated.emit(velocity.length())

	return true


func _try_activate_boost() -> bool:
	var impulse := boost.try_activate(velocity)

	if impulse.length_squared() <= 0.0001:
		return false

	velocity += impulse

	boost_activated.emit(
		self,
		impulse.normalized()
	)

	return true


func _move_by_velocity(delta: float) -> void:
	previous_global_position = global_position
	_last_motion_from = global_position

	global_position += velocity * delta

	_last_motion_to = global_position


func _on_area_entered(area: Area2D) -> void:
	var target := _find_damage_target(area)

	damage_dealer.try_deal_damage(
		target,
		self,
		velocity
	)


func _on_body_entered(body: Node2D) -> void:
	var target := _find_damage_target(body)

	damage_dealer.try_deal_damage(
		target,
		self,
		velocity
	)


func _find_damage_target(collider: Node) -> Node:
	if collider == null:
		return null

	if collider.has_method("take_damage"):
		return collider

	var current := collider.get_parent()

	while current != null:
		if current.has_method("take_damage"):
			return current

		current = current.get_parent()

	return collider


func _on_damage_dealt(
	target: Node,
	attacker: Node,
	damage_info: Dictionary
) -> void:
	var enriched_damage_info := damage_info.duplicate()

	enriched_damage_info["movement_from"] = _last_motion_from
	enriched_damage_info["movement_to"] = _last_motion_to
	enriched_damage_info["previous_global_position"] = previous_global_position
	enriched_damage_info["attacker_radius"] = get_collision_radius()

	hit_confirmed.emit(
		target,
		attacker,
		enriched_damage_info
	)
