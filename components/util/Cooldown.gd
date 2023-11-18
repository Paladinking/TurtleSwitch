class_name Cooldown
extends Node


@export_range(0., 100.)
var cooldown: float = 1.

var _on_cooldown: bool = false
var _time_left: float = 0.

signal on_cooldown_tick(left: float, cooldown: float)
signal on_cooldown_changed(on_cooldown: bool)

func _physics_process(delta):
    if self._time_left > 0.:
        self._time_left = max(self._time_left - delta, 0.)

        if self._time_left == 0.:
            self.on_cooldown_changed.emit(false)
            self._on_cooldown = false

    self.on_cooldown_tick.emit(self._time_left, self.cooldown)

func use_cooldown() -> bool:
    if self._on_cooldown:
        return false

    self._on_cooldown = true

    self.on_cooldown_changed.emit(true)
    self._time_left = self.cooldown

    return true
