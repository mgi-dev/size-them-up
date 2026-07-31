extends RigidBody2D


class_name Box


@onready var collision_shape = $CollisionShape2D
var contacts = []


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _integrate_forces(state):
	if $WithContact:
		$WithContact.delegated_integrate_forces(state)
