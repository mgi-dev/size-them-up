extends Node2D

@onready var info_text: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	info_text.text = get_tree().current_scene.name 
	info_text.text += " | god mode : "
	info_text.text += "on" if GameState.god_mode else "off" 
