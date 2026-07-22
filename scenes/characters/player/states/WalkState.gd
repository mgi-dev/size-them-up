extends PlayerState

class_name WalkState

	
func enter():
	pass


func exit():
	pass


func update(delta):
	# This is coupled, could use a variant to get value from parent.
	# But seems convoluted for small gain, I accept this for now.
	var direction = Input.get_axis("player_move_left", "player_move_right")
	if direction != 0:
		player.velocity.x = move_toward(
			player.velocity.x, 
			direction * player.SPEED, 
			player.ACCELERATION * delta
		)
		player.animated_sprite.flip_h = player.velocity.x < 0
		player.animated_sprite.play("walk")
	else:
		player.velocity.x = 0

	super.update(delta)
