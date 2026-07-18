extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_interact():
	SignalBus.multi_resize_mode_changed.emit(true)
	SignalBus.important_item_collected.emit()
	queue_free()
