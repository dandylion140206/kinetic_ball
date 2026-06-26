class_name HitStopReceiver
extends Node

var _stop_end_msec: int = 0


func is_hit_stopped() -> bool:
	return Time.get_ticks_msec() < _stop_end_msec


func request_hit_stop(duration: float) -> void:
	if duration <= 0.0:
		return

	var now := Time.get_ticks_msec()
	var new_end_msec := now + int(duration * 1000.0)

	_stop_end_msec = maxi(_stop_end_msec, new_end_msec)


func clear_hit_stop() -> void:
	_stop_end_msec = 0
