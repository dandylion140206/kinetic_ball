class_name ImpactSparkEffect
extends Node2D

@export_group("Spark Count")
@export_range(1, 30, 1) var spark_count_min: int = 5
@export_range(1, 40, 1) var spark_count_max: int = 9

@export_group("Fan")
@export_range(10.0, 180.0, 1.0) var arc_degrees: float = 110.0
@export_range(0.0, 30.0, 1.0) var angle_jitter_degrees: float = 4.0

@export_group("Motion")
@export_range(0.0, 80.0, 1.0) var start_distance_min: float = 6.0
@export_range(0.0, 120.0, 1.0) var start_distance_max: float = 14.0
@export_range(100.0, 3000.0, 10.0) var speed_min: float = 900.0
@export_range(100.0, 4000.0, 10.0) var speed_max: float = 1900.0
@export_range(100.0, 10000.0, 50.0) var deceleration_min: float = 4500.0
@export_range(100.0, 15000.0, 50.0) var deceleration_max: float = 8500.0

@export_group("Shape")
@export_range(5.0, 300.0, 1.0) var length_min: float = 8.0
@export_range(5.0, 400.0, 1.0) var length_max: float = 30.0
@export_range(1.0, 40.0, 0.5) var thickness_min: float = 1.0
@export_range(1.0, 60.0, 0.5) var thickness_max: float = 4.0

@export_group("Lifetime")
@export_range(0.02, 0.5, 0.01) var lifetime_min: float = 0.08
@export_range(0.02, 0.5, 0.01) var lifetime_max: float = 0.14
@export_range(0.5, 5.0, 0.1) var fade_power: float = 1.6

@export_group("Color")
@export var spark_color: Color = Color(1.0, 0.78, 0.16, 1.0)

var _sparks: Array[Dictionary] = []
var _age: float = 0.0
var _lifetime: float = 0.1


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	_age += delta

	if _age >= _lifetime:
		queue_free()
		return

	_update_sparks(delta)
	queue_redraw()


func _draw() -> void:
	if _lifetime <= 0.0:
		return

	var progress := clampf(_age / _lifetime, 0.0, 1.0)
	var alpha := pow(1.0 - progress, fade_power)

	for spark in _sparks:
		var position: Vector2 = spark["position"]
		var direction: Vector2 = spark["direction"]
		var length: float = spark["length"]
		var thickness: float = spark["thickness"]

		var current_length := length * (0.75 + 0.25 * alpha)

		var color := spark_color
		color.a *= alpha

		_draw_rect_spark(
			position,
			direction,
			current_length,
			thickness,
			color
		)


func play(
	spawn_position: Vector2,
	normal_direction: Vector2,
	strength_ratio: float
) -> void:
	if normal_direction.length_squared() <= 0.0001:
		queue_free()
		return

	strength_ratio = clampf(strength_ratio, 0.0, 1.0)

	global_position = spawn_position
	global_rotation = 0.0

	_age = 0.0

	_lifetime = lerpf(
		lifetime_min,
		lifetime_max,
		strength_ratio
	)

	_generate_sparks(
		normal_direction.normalized(),
		strength_ratio
	)

	set_process(true)
	queue_redraw()


func _generate_sparks(
	normal_direction: Vector2,
	strength_ratio: float
) -> void:
	_sparks.clear()

	var spark_count := roundi(
		lerpf(
			float(spark_count_min),
			float(spark_count_max),
			strength_ratio
		)
	)

	spark_count = maxi(1, spark_count)

	var half_arc := arc_degrees * 0.5

	for i in spark_count:
		var ratio := 0.5

		if spark_count > 1:
			ratio = float(i) / float(spark_count - 1)

		var angle_degrees := lerpf(
			-half_arc,
			half_arc,
			ratio
		)

		angle_degrees += randf_range(
			-angle_jitter_degrees,
			angle_jitter_degrees
		)

		var direction := normal_direction.rotated(
			deg_to_rad(angle_degrees)
		).normalized()

		var start_distance := randf_range(
			start_distance_min,
			start_distance_max
		)

		var start_position := direction * start_distance

		var speed := lerpf(
			speed_min,
			speed_max,
			strength_ratio
		)

		speed *= randf_range(0.85, 1.15)

		var deceleration := lerpf(
			deceleration_min,
			deceleration_max,
			strength_ratio
		)

		deceleration *= randf_range(0.85, 1.15)

		var length := lerpf(
			length_min,
			length_max,
			strength_ratio
		)

		length *= randf_range(0.75, 1.15)

		var thickness := lerpf(
			thickness_min,
			thickness_max,
			strength_ratio
		)

		thickness *= randf_range(0.85, 1.15)

		_sparks.append({
			"position": start_position,
			"velocity": direction * speed,
			"direction": direction,
			"deceleration": deceleration,
			"length": length,
			"thickness": thickness,
		})


func _update_sparks(delta: float) -> void:
	for i in _sparks.size():
		var spark := _sparks[i]

		var position: Vector2 = spark["position"]
		var velocity: Vector2 = spark["velocity"]
		var deceleration: float = spark["deceleration"]

		position += velocity * delta

		velocity = velocity.move_toward(
			Vector2.ZERO,
			deceleration * delta
		)

		spark["position"] = position
		spark["velocity"] = velocity

		_sparks[i] = spark


func _draw_rect_spark(
	position: Vector2,
	direction: Vector2,
	length: float,
	thickness: float,
	color: Color
) -> void:
	if direction.length_squared() <= 0.0001:
		return

	direction = direction.normalized()

	var half_length := length * 0.5
	var half_thickness := thickness * 0.5

	var perpendicular := Vector2(
		-direction.y,
		direction.x
	)

	var start := position - direction * half_length
	var end := position + direction * half_length

	var points := PackedVector2Array([
		start - perpendicular * half_thickness,
		start + perpendicular * half_thickness,
		end + perpendicular * half_thickness,
		end - perpendicular * half_thickness,
	])

	draw_colored_polygon(
		points,
		color
	)
