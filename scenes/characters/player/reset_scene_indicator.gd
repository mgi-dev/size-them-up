extends AnimatedSprite2D

@onready var reset_in_progress = false


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.reset_scene_start.connect(reset_scene_start_animation)
	SignalBus.reset_scene_cancel.connect(reset_scene_cancel_animation)
	animation_finished.connect(on_animation_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func reset_scene_start_animation():
	reset_in_progress = true
	play("reset")
	


func reset_scene_cancel_animation():
	stop()
	reset_in_progress = false
	play("default")


func on_animation_finished():
	if reset_in_progress == true:
		SignalBus.reset_scene_animation_completed.emit()
	
