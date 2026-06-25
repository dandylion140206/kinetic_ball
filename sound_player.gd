class_name SoundPlayer
extends Node

@export var sound: AudioStream
@export var bus_name: StringName = &"SFX"

@export_range(-15.0, 10.0, 0.2) var volume_db: float = 0.0
@export_range(0.75, 1.25, 0.01) var pitch_min: float = 1.0
@export_range(0.75, 1.25, 0.01) var pitch_max: float = 1.0


func play_at(global_position: Vector2) -> void:
	if sound == null:
		return

	var audio_player := AudioStreamPlayer2D.new()

	audio_player.stream = sound
	audio_player.bus = _get_valid_bus_name()
	audio_player.global_position = global_position
	audio_player.volume_db = volume_db
	audio_player.pitch_scale = randf_range(pitch_min, pitch_max)

	var parent := get_tree().current_scene
	if parent == null:
		parent = get_tree().root

	parent.add_child(audio_player)

	audio_player.finished.connect(
		func() -> void:
			audio_player.queue_free()
	)

	audio_player.play()


func _get_valid_bus_name() -> StringName:
	var bus_index := AudioServer.get_bus_index(bus_name)

	if bus_index == -1:
		push_warning("SoundPlayer: Audio bus not found: %s. Fallback to Master." % bus_name)
		return &"Master"

	return bus_name
