extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.multi_resize_mode_changed.emit(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
