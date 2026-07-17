extends Node



enum GAME_EVENT {
	EMPTY_GAUGE, 
	FULL_GAUGE, 
	PLAYER_CLOSE_TO_RESIZABLE,
	PLAYER_JUMP
}


enum RESIZE_MODE {ALL, VERTICAL, HORIZONTAL}

const CLIMBABLE_GROUP = "climbable"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
