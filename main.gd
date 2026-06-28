extends Node

@onready var ball: Ball = $Ball
@onready var speed_graph: SpeedGraph = $CanvasLayer/SpeedGraph
@onready var vfx_spawner: VFXSpawner = $VFXSpawner
@onready var target_spawner: TargetSpawner = $TargetSpawner
@onready var health_bar_layer: HealthBarLayer = $HealthBarLayer
@onready var hit_reaction_director: HitReactionDirector = $HitReactionDirector
@onready var camera_shake: CameraShake = $Camera2D/CameraShake


func _ready() -> void:
	ball.speed_updated.connect(speed_graph.add_value)
	ball.boost_activated.connect(vfx_spawner.spawn_boost_smoke)
	ball.hit_confirmed.connect(hit_reaction_director.play_hit_reaction)

	hit_reaction_director.camera_shake_requested.connect(
		camera_shake.request_shake
	)

	target_spawner.target_spawned.connect(health_bar_layer.register_health_owner)

	for target in target_spawner.targets:
		health_bar_layer.register_health_owner(target)
