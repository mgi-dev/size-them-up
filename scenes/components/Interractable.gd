extends Area2D

"""
Connect to the on_player_interact_signal.
parent must implement on_interact
"""


@export var player_detector = CollisionShape2D



func _ready():
	SignalBus.player_interact.connect(on_player_interact)


func _process(delta):
	pass


func on_player_interact():
	if is_player_colliding():
		if get_parent().on_interact:
			get_parent().on_interact()


func is_player_colliding() -> bool:
	for body in get_overlapping_bodies():
		if body is Player:
			return true
	return false
