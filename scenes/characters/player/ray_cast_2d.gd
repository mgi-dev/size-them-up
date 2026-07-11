extends RayCast2D

@onready var visible_laser = $Line2D


func _process(delta):
	handle_colliding(delta)

	
func handle_colliding(delta):
	var mouse_position = to_local(get_viewport().get_mouse_position())	
	target_position = mouse_position
	force_raycast_update()
	
	if is_colliding():
		# debug()
		emit_collide_event()
		var collision_position = to_local(get_collision_point())
		target_position = collision_position
		visible_laser.set_point_position(1, collision_position)
	else:
		emit_non_collide_event()
		visible_laser.set_point_position(1, mouse_position)
		

func emit_collide_event():
	var collider = get_collider()
	var shape_index = get_collider_shape()
	var owner_id = collider.shape_find_owner(shape_index)
	var collision_shape = collider.shape_owner_get_owner(owner_id)
	
	SignalBus.resize_ray_collided.emit(collision_shape)


func emit_non_collide_event():
	SignalBus.resize_ray_collided.emit(null)
	



### DEBUG MODE.

var false_count = 0
var true_count = 0
	
func debug():
	if is_colliding():
		true_count += 1
	else:
		false_count += 1
	print("false: ", false_count, ", true: ", true_count)	
	
