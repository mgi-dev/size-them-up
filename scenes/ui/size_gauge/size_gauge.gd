extends Node2D

@onready var gauge = $ProgressBar

@export var max_value = 2.0
@export var min_value = 0.0

@export var start_value = 0.0

func _ready():
	SignalBus.resized.connect(fill_the_gauge)
	gauge.min_value = min_value
	gauge.max_value = max_value
	gauge.value = start_value
	SignalBus.gauge_changed.emit(to_percentage(gauge.value))


func fill_the_gauge(amount: float):
	print("resized by ", amount)
	if amount > 0:
		# shape has been sized up, draining the gauge.
		gauge.value -= abs(amount)
	elif amount < 0:
		# shape has been sized down, filling the gauge.
		gauge.value += abs(amount)
	
	SignalBus.gauge_changed.emit(to_percentage(gauge.value))


func to_percentage(value: float) -> float:
	return value * 100 / max_value
