extends Area2D

class_name Door

@onready var collision_shape = $CollisionShape2D
@onready var background_sprite = $backgroud
@onready var door_animation = $DoorAnimation
@onready var door_audio = $AudioStreamPlayer
@onready var door_status = $door_status


@export var is_open : bool = false
@export var next_scene : PackedScene

func _ready():
	background_sprite.modulate  = Color("1A1E29")

	if next_scene:
		door_status.modulate = Color("a6cfcf")
	else:
		door_status.modulate = Color("a01b02ff")


func _process(delta):
	pass

func on_interact():
	if next_scene:
		if !is_open:
			open_door()
			is_open = true
		else:
			close_door()
			is_open = false


func open_door():
	door_animation.play("open")
	door_audio.play()
	await door_animation.animation_finished
	SignalBus.next_level.emit(next_scene)
	
	
	
func close_door():
	door_animation.play("close")
	door_audio.play()
	
	
func reset_open():
	door_animation.play("reset_open")


func reset_close():
	door_animation.play("RESET")

	
		
