class_name BallCollisionHandler
extends Node

signal damage_receiver_entered(receiver: DamageReceiver)

@export var hit_area_path: NodePath = NodePath("../HitArea")

@onready var hit_area: Area2D = get_node_or_null(hit_area_path) as Area2D


func _ready() -> void:
	if hit_area == null:
		push_warning("BallCollisionHandler: hit_area is not assigned.")
		return

	hit_area.area_entered.connect(_on_area_entered)
	hit_area.body_entered.connect(_on_body_entered)


func _on_area_entered(area: Area2D) -> void:
	var receiver := _find_damage_receiver(area)

	if receiver == null:
		return

	damage_receiver_entered.emit(receiver)


func _on_body_entered(body: Node2D) -> void:
	var receiver := _find_damage_receiver(body)

	if receiver == null:
		return

	damage_receiver_entered.emit(receiver)


func _find_damage_receiver(collider: Node) -> DamageReceiver:
	var current := collider

	while current != null:
		var receiver := _find_direct_damage_receiver(current)

		if receiver != null:
			return receiver

		current = current.get_parent()

	return null


func _find_direct_damage_receiver(node: Node) -> DamageReceiver:
	if node is DamageReceiver:
		return node as DamageReceiver

	for child in node.get_children():
		if child is DamageReceiver:
			return child as DamageReceiver

	return null
