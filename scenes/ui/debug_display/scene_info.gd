extends Node2D

@onready var info_text: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	info_text.text = get_tree().current_scene.name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
