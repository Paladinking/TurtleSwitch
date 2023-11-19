class_name Cooldown
extends Node


@export_range(0., 100.)
var cooldown: float = 1.

var _time_left: float = 0.

signal on_cooldown_tick(left: float, cooldown: float)
signal on_cooldown_ended
signal on_cooldown_begin

func _physics_process(delta):
	if _time_left > 0.:
		_time_left = max(_time_left - delta, 0.)

		if _time_left == 0.:
			on_cooldown_ended.emit()

	on_cooldown_tick.emit(_time_left, cooldown)

func use_cooldown() -> bool:
	if _time_left > 0.:
		return false

	_time_left = cooldown

	on_cooldown_begin.emit()
	return true

func reset():
	on_cooldown_begin.emit()
	_time_left = cooldown

func is_done() -> bool:
	return _time_left == 0

func set_duration(time: float):
	_time_left = time
	cooldown = time
