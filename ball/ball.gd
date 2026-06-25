class_name Ball
extends Area2D

signal speed_updated(speed: float)
signal boost_activated(
	follow_node: Node2D,
	boost_direction: Vector2
)

@export var movement_stats: MovementStats

var velocity: Vector2 = Vector2.ZERO

@onready var movement: Movement = $Movement
@onready var boost: Boost = $Boost
@onready var damage_dealer: DamageDealer = $DamageDealer


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	var target_position := get_global_mouse_position()

	velocity = movement.calculate_velocity(
		velocity,
		global_position,
		target_position,
		movement_stats,
		delta
	)

	if Input.is_action_just_pressed("primary_action"):
		var impulse := boost.try_activate(velocity)

		if impulse.length_squared() > 0.0001:
			velocity += impulse
			boost_activated.emit(
				self,
				impulse.normalized()
			)

	global_position += velocity * delta

	speed_updated.emit(velocity.length())


func get_velocity_direction() -> Vector2:
	if velocity.length_squared() <= 0.0001:
		return Vector2.ZERO

	return velocity.normalized()


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
