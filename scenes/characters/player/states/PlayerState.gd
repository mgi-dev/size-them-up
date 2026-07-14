class_name PlayerState

extends RefCounted


var player: CharacterBody2D


func _init(_player):
	player = _player
	
	
func enter():
	pass

func exit():
	pass

func update(delta):
	apply_gravity(delta)


func apply_gravity(delta):
	if not player.is_on_floor() and not player.is_climbing:
		player.velocity += player.get_gravity() * delta


func _to_string():
	return get_script().resource_path.get_file().get_basename()
	
