extends Area2D

class_name Ladder

@onready var top_ladder_collision_zone: CollisionShape2D = $TopLadderZone/CollisionShape2D

func _ready():
	pass


func _process(delta):
	pass


func _input(event):
	if event.is_action_pressed("player_down"):
		top_ladder_collision_zone.disabled = true
		
	if event.is_action_released("player_down"):
		top_ladder_collision_zone.disabled = false
