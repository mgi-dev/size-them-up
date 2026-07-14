extends Area2D

class_name Ladder

@onready var top_ladder_collision_zone: CollisionShape2D = $TopLadderZone/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
func _input(event):
	if event.is_action_pressed("player_down"):
		print("disable")
		top_ladder_collision_zone.disabled = true
		
		print("enable")
	if event.is_action_released("player_down"):
		top_ladder_collision_zone.disabled = false
