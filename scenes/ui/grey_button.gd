@tool

extends AnimatedSprite2D

@export var text: String

# Called when the node enters the scene tree for the first time.
func _ready():
	if text:
		$Label.text = text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
