extends Node


@onready var ball: Ball = $Ball
@onready var speed_graph: SpeedGraph = $CanvasLayer/SpeedGraph
@onready var vfx_layer: VFXSpawner = $VFXLayer


func _ready() -> void:
	ball.speed_updated.connect(speed_graph.add_value)
	ball.boost_activated.connect(vfx_layer.spawn_boost_smoke)

func _process(delta: float) -> void:
	# デバッグ用: ゲームスピードを遅くする
	if Input.is_key_pressed(KEY_SHIFT):
		Engine.time_scale = 0.35
	else:
		Engine.time_scale = 1.0
