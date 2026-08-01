extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().contacts = []


func delegated_integrate_forces(parent_state):
	# remember to set : contact monitor: true and Max Contact Reported.
	get_parent().contacts.clear()

	for i in range(parent_state.get_contact_count()):
		
		var _contact = parent_state.get_contact_collider_object(i)
		if _contact is Resizable or _contact is RotatingPlateform or _contact is Box:
			get_parent().contacts.append(_contact)
	
