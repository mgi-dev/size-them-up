extends RefCounted


# Called when the node enters the scene tree for the first time.
class_name State

	
func enter():
	pass


func exit():
	pass


func update(delta):
	pass


func _to_string():
	return get_script().resource_path.get_file().get_basename()
	
