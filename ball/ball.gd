class_name Ball
extends Area2D

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

@onready var movement: Movement = $Movement
@onready var boost: Boost = $Boost
@onready var damage_dealer: DamageDealer = $DamageDealer
@onready var hit_stop: HitStopReceiver = $HitStopReceiver


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
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

	global_position += velocity * delta

	speed_updated.emit(velocity.length())


func _try_cancel_hit_stop_with_boost(delta: float) -> bool:
	if not Input.is_action_just_pressed("primary_action"):
		return false

	if not _try_activate_boost():
		return false

	hit_stop.clear_hit_stop()

	global_position += velocity * delta

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


func _on_area_entered(area: Area2D) -> void:
	damage_dealer.try_deal_damage(
		area,
		self,
		velocity
	)


func _on_body_entered(body: Node2D) -> void:
	damage_dealer.try_deal_damage(
		body,
		self,
		velocity
	)


func _on_damage_dealt(
	target: Node,
	attacker: Node,
	damage_info: Dictionary
) -> void:
	hit_confirmed.emit(
		target,
		attacker,
		damage_info
	)
