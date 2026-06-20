extends Node

func _ready() -> void:
	$Ball.speed_updated.connect($CanvasLayer/SpeedGraph.add_value)
