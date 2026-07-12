extends Node

# values are true by default to allow scaling in debug mode.
# if a gauge is present in the scene it will send 0 on_ready()
var _can_size_up: bool = true
var _can_size_down: bool = true

func _ready():
	SignalBus.gauge_changed.connect(on_gauge_changed)


func on_gauge_changed(percentage: float) -> void:
	if percentage >= 100:
		_can_size_up = true
		_can_size_down = false
	elif percentage <= 0:
		_can_size_up = false
		_can_size_down = true
	else:
		_can_size_up = true
		_can_size_down = true


func can_size_up() -> bool:
	return _can_size_up
	
func can_size_down() -> bool:
	return _can_size_down
