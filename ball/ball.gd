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
	damage_info: DamageInfo
)

@export var steering_stats: BallSteeringStats

@onready var input_controller: BallInputController = $BallInputController
@onready var steering: BallSteering = $BallSteering
@onready var motion: BallMotion = $BallMotion
@onready var boost_controller: BoostController = $BoostController
@onready var damage_dealer: DamageDealer = $DamageDealer
@onready var hit_stop: HitStopReceiver = $HitStopReceiver
@onready var collision_handler: BallCollisionHandler = $BallCollisionHandler


func _ready() -> void:
	collision_handler.damage_receiver_entered.connect(_on_damage_receiver_entered)
	damage_dealer.damage_dealt.connect(_on_damage_dealt)
	boost_controller.boost_activated.connect(_on_boost_activated)


func _process(delta: float) -> void:
	if hit_stop.is_hit_stopped():
		if _try_cancel_hit_stop_with_boost(delta):
			return

		speed_updated.emit(motion.get_speed())
		return

	_process_normal_movement(delta)


func get_velocity_direction() -> Vector2:
	return motion.get_velocity_direction()


func request_hit_stop(duration: float) -> void:
	if hit_stop == null:
		return

	hit_stop.request_hit_stop(duration)


func _process_normal_movement(delta: float) -> void:
	var target_position := input_controller.get_movement_target(self)

	var next_velocity := steering.calculate_velocity(
		motion.get_velocity(),
		global_position,
		target_position,
		steering_stats,
		delta
	)

	motion.set_velocity(next_velocity)

	if input_controller.is_boost_requested():
		boost_controller.try_activate()

	motion.move(delta)

	speed_updated.emit(motion.get_speed())


func _try_cancel_hit_stop_with_boost(delta: float) -> bool:
	if not input_controller.is_boost_requested():
		return false

	if not boost_controller.try_activate():
		return false

	hit_stop.clear_hit_stop()

	motion.move(delta)

	speed_updated.emit(motion.get_speed())

	return true


func _on_damage_receiver_entered(receiver: DamageReceiver) -> void:
	damage_dealer.try_deal_damage(
		receiver,
		self,
		motion.get_velocity()
	)


func _on_damage_dealt(
	target: Node,
	attacker: Node,
	damage_info: DamageInfo
) -> void:
	hit_confirmed.emit(
		target,
		attacker,
		damage_info
	)


func _on_boost_activated(
	follow_node: Node2D,
	boost_direction: Vector2
) -> void:
	boost_activated.emit(
		follow_node,
		boost_direction
	)
