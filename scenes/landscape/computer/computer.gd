extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_interact():
	$Flashing.is_flashing = false
	var parent = get_parent()
	if parent:
		if parent.has_method("on_interact"):
			parent.on_interact(self)
