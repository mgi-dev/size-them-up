extends Node


var _can_size_up: bool = false
var _can_size_down: bool = false
var resize_ray_target: CollisionShape2D

func _ready():
	SignalBus.gauge_changed.connect(on_gauge_changed)
	SignalBus.resize_ray_collided.connect(on_resize_ray_target_changed)

func on_gauge_changed(percentage: float) -> void:
	if percentage >= 100:
		_can_size_up = false
		_can_size_down = true
	elif percentage <= 0:
		_can_size_up = true
		_can_size_down = false
	else:
		_can_size_up = true
		_can_size_down = true

func on_resize_ray_target_changed(target: CollisionShape2D):
	resize_ray_target = target

func can_size_up() -> bool:
	return _can_size_up
	
func can_size_down() -> bool:
	return _can_size_down
