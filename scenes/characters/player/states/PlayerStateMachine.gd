extends RefCounted

class_name PlayerStateMachine

var player: CharacterBody2D
var current_state: PlayerState

var idle_state: IdleState
var walk_state: WalkState
var jump_state: JumpState
var climb_state: ClimbState

func _init(_player):
	player = _player
	idle_state = IdleState.new(_player)
	walk_state = WalkState.new(_player)
	jump_state = JumpState.new(_player)
	climb_state = ClimbState.new(_player)
	
	current_state = idle_state

func set_state(next_state: PlayerState):
	# react my friend, i miss you sometimes. Soon we will mess things together again.
	# dedicated function for each state ?

	current_state.exit()
	current_state = next_state
	current_state.enter()
	
func update(delta):
	current_state.update(delta)
