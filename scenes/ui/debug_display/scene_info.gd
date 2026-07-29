extends Node2D

@onready var info_text: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	info_text.text = get_tree().current_scene.name 
	info_text.text += " | god mode : "
	info_text.text += "on" if GameState.god_mode else "off" 
	info_text.text += " | build: " + get_build_number() 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func get_build_number() -> String: 
	var file = FileAccess.open("res://settings.json", FileAccess.READ)
	var settings = JSON.parse_string(file.get_as_text())
	return str(settings.build)
