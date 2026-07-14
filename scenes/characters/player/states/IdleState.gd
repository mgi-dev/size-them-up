extends PlayerState

class_name IdleState

	
func enter():
	pass

func exit():
	pass

func update(delta):
	player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	player.animated_sprite.play("idle")
	
	super.update(delta)
