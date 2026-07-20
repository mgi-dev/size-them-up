extends RefCounted

class_name StateMachine

var states
var current_state: State


func _init(_states):
	states = _states
	current_state = states[states.keys()[0]]


func set_state(next_state: State):
	# react my friend, i miss you sometimes. Soon we will mess things together again.
	# dedicated function for each state ?
	if next_state != current_state:
		current_state.exit()
		current_state = next_state
		current_state.enter()
	
func update(delta):
	current_state.update(delta)
