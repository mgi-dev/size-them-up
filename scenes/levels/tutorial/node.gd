extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func on_interact(caller):
	print("allo ?")
	if caller == $Computer:
		print("c'est chicko")
		var email = $"../Camera/Email"
		email.display = true
