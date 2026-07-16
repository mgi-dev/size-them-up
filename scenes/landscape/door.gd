extends Area2D

@onready var collision_shape = $CollisionShape2D
@onready var background_sprite = $backgroud
@onready var door_animation = $DoorAnimation
@onready var door_audio = $AudioStreamPlayer



@export var is_open : bool = false
@export var next_scene : PackedScene

func _ready():
	SignalBus.player_interact.connect(on_player_interact)
	background_sprite.modulate  = Color("1A1E29")


func _process(delta):
	pass


func on_player_interact():
	if is_player_colliding():
		if !is_open:
			open_door()
			is_open = true
		else:
			close_door()
			is_open = false
	
func is_player_colliding() -> bool:
	for body in get_overlapping_bodies():
		if body is Player:
			return true
	return false


func open_door():
	door_animation.play("open")
	door_audio.play()
	await door_animation.animation_finished
	if next_scene:
		var node := next_scene.instantiate()
		get_tree().change_scene_to_node(node)
	else:
		print("NO NEXT SCENE")
	
	
	
func close_door():
	door_animation.play("close")
	door_audio.play()
