extends Node

func _ready() -> void:
	$Ball.speed_updated.connect($CanvasLayer/SpeedGraph.add_value)

func _process(delta: float) -> void:
	# デバッグ用: ゲームスピードを遅くする
	if Input.is_key_pressed(KEY_SHIFT):
		Engine.time_scale = 0.35
	else:
		Engine.time_scale = 1.0
