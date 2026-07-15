extends PlayerState

class_name JumpState


func enter():
	SignalBus.player_jump.emit()

func update(delta):
	player.velocity.y = player.JUMP_VELOCITY
	super.update(delta)
