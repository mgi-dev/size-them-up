extends Area2D

"""
Connect to the on_player_interact_signal.
parent must implement on_interact
"""


@export var player_detector = CollisionShape2D
@export var glowing_area: Polygon2D

@export var reusable: bool = false
var already_interacted: bool = false
var glowing = false


func _ready():
	SignalBus.player_interact.connect(on_player_interact)



func _process(delta):
	set_glowing_area()
	

func set_glowing_area():
	if glowing_area:
		if is_player_colliding():
			if already_interacted and !reusable:
				glowing_area.color = Color("f2e43200")
			else:
				glowing_area.color = Color("f2e432a6")
		else:
			glowing_area.color = Color("f2e43200")

func on_player_interact():
	if is_player_colliding():
		if !already_interacted or reusable:
			if get_parent().on_interact:
				get_parent().on_interact()
		already_interacted = true
		

func is_player_colliding() -> bool:
	for body in get_overlapping_bodies():
		if body is Player:
			return true
	return false
