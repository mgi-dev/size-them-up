extends PlayerState

class_name ClimbState

	
func enter():
	player.is_climbing = true

func exit():
	player.is_climbing = false

func update(delta):
	var direction_y = Input.get_axis("player_climb", "player_down")
	if direction_y:
		player.velocity.y = move_toward(
			player.velocity.y,
			direction_y * player.CLIMB_SPEED, 
			player.ACCELERATION * delta
		)
		
	else:
		player.velocity.y = 0
	
	var direction_x = Input.get_axis("player_move_right", "player_move_left")
	if direction_x:
		player.velocity.x = move_toward(
			player.velocity.x, 
			direction_x * player.CLIMB_SPEED, 
			player.ACCELERATION * delta
		)
		player.animated_sprite.flip_h = player.velocity.x < 0
	else:
		player.velocity.x = 0
		
	super.update(delta)
