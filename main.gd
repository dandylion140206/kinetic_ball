extends Node

@onready var ball: Ball = $Ball
@onready var speed_graph: SpeedGraph = $CanvasLayer/SpeedGraph
@onready var vfx_layer: VFXSpawner = $VFXLayer
@onready var target_spawner: TargetSpawner = $TargetSpawner
@onready var health_bar_layer: HealthBarLayer = $HealthBarLayer


func _ready() -> void:
	ball.speed_updated.connect(speed_graph.add_value)
	ball.boost_activated.connect(vfx_layer.spawn_boost_smoke)

	target_spawner.target_spawned.connect(health_bar_layer.register_target)

	for target in target_spawner.targets:
		health_bar_layer.register_target(target)
