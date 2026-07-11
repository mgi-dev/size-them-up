extends RayCast2D

class_name ResizeGun

@onready var visible_laser = $Line2D
@export var laser_min_width: float = 0.0
@export var laser_max_width: float = 10.0
@export var laser_ready_speed: float = 0.2

var is_resizing_laser_enabled: bool = false

func _ready():
	visible_laser.width = laser_min_width

func _process(delta):
	handle_laser_visible_width()
	select_laser_color()
	handle_colliding(delta)


func handle_laser_visible_width() -> void:
	if Input.is_action_pressed("size_up") or Input.is_action_pressed("size_down"):
		if visible_laser.width <= laser_max_width:
			visible_laser.width += laser_ready_speed
			if visible_laser.width >= laser_max_width:
				# Avoid going over limit.
				visible_laser.width = laser_max_width
				is_resizing_laser_enabled = true
	else:
		# no mouse click --> laser reset.
		is_resizing_laser_enabled = false
		visible_laser.width = laser_min_width
		
func select_laser_color() -> void:
	if Input.is_action_pressed("size_up"): 
		visible_laser.default_color = Color(0.856, 0.002, 0.001, 1.0)
	elif Input.is_action_pressed("size_down"):
		visible_laser.default_color = Color(0.108, 0.345, 1.0, 1.0)
	
func handle_colliding(delta):
	var mouse_position = to_local(get_viewport().get_mouse_position())	
	target_position = mouse_position
	force_raycast_update()

	if is_colliding():
		# debug()
		var collision_position = to_local(get_collision_point())
		target_position = collision_position
		visible_laser.set_point_position(1, collision_position)
		handle_resizing()
	else:
		visible_laser.set_point_position(1, mouse_position)
		

func handle_resizing():
	if is_resizing_laser_enabled and is_target_resizable():
		if Input.is_action_pressed("size_up"): 
			SignalBus.resize_ray_resize_up.emit(get_collision_shape())
		elif Input.is_action_pressed("size_down"):
			SignalBus.resize_ray_resize_down.emit(get_collision_shape())


func is_target_resizable() -> bool:
	var collider = get_collider()
	return collider is Resizable

		
func get_collision_shape() -> CollisionShape2D:
	var collider = get_collider()
	var shape_index = get_collider_shape()
	var owner_id = collider.shape_find_owner(shape_index)
	return collider.shape_owner_get_owner(owner_id)



### DEBUG MODE.

var false_count = 0
var true_count = 0
	
func debug():
	if is_colliding():
		true_count += 1
	else:
		false_count += 1
	print("false: ", false_count, ", true: ", true_count)	
	
