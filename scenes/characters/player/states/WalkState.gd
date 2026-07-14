extends PlayerState

class_name WalkState

	
func enter():
	pass


func exit():
	pass


func update(delta):
	# This is coupled, could use a variant to get value from parent.
	# But seems convoluted for small gain, I accept this for now.
	var direction = Input.get_axis("player_move_right", "player_move_left")
	if direction:
		player.velocity.x = direction * player.SPEED
		player.animated_sprite.flip_h = player.velocity.x < 0
		player.animated_sprite.play("walk")

	super.update(delta)
