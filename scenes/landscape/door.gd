extends Area2D

@onready var collision_shape = $CollisionShape2D
@onready var door_animation = $DoorAnimation


@export var is_open : bool = false
@export var next_scene : PackedScene

func _ready():
	SignalBus.player_interact.connect(on_player_interact)


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
	await door_animation.animation_finished
	var node := next_scene.instantiate()
	get_tree().change_scene_to_node(node)
	
	
func close_door():
	door_animation.play("open", -1, -1.0)
