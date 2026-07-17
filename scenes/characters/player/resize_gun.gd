extends RayCast2D

class_name ResizeGun

@onready var visible_laser = $Line2D
@export var laser_min_width: float = 0.0
@export var laser_max_width: float = 10.0
@export var laser_ready_speed: float = 0.2

@onready var sound_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_size_down : AudioStreamPlayer2D = $AudioSizeDown
@onready var audio_size_up : AudioStreamPlayer2D = $AudioSizeUp

var audio_size_down_playing = false
var audio_size_up_playing = false


var is_resizing_laser_enabled: bool = false

func _ready():
	visible_laser.width = laser_min_width
	for node in get_tree().get_nodes_in_group(Enums.CLIMBABLE_GROUP):
		if node is CollisionObject2D:
			add_exception(node)


func _process(delta):
	manage_sound_and_find_a_better_name()
	handle_laser_visible_width()
	select_laser_color()
	handle_colliding(delta)
	


func manage_sound_and_find_a_better_name():
	# TODO: scale db gradually.
	if Input.is_action_just_pressed("size_up") or Input.is_action_just_pressed("size_down"):		
		sound_player.play()
	if Input.is_action_just_released("size_up") or Input.is_action_just_released("size_down"):
		sound_player.stop()


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
	debug()
	var far_away_position = to_local(get_global_mouse_position()).normalized() * 5000 
	target_position = far_away_position
	force_raycast_update()

	if is_colliding():
		var collision_position = to_local(get_collision_point())
		target_position = collision_position
		visible_laser.set_point_position(1, collision_position)
		handle_resizing()
	else:
		visible_laser.set_point_position(1, far_away_position)
		

func handle_resizing():
	if is_resizing_laser_enabled and is_target_resizable():
		if Input.is_action_pressed("size_up"): 
			if !audio_size_up_playing:
				audio_size_up_playing = true
				audio_size_up.play()
			SignalBus.resize_ray_resize_up.emit(get_collision_shape(), GameState.current_resize_mode)
		elif Input.is_action_pressed("size_down"):
			if !audio_size_down_playing:
				audio_size_down_playing = true
				audio_size_down.play()
			SignalBus.resize_ray_resize_down.emit(get_collision_shape(), GameState.current_resize_mode)
		else:
			if audio_size_down_playing:
				audio_size_down.stop()
				audio_size_down_playing = false
			if audio_size_up_playing:
				audio_size_up.stop()
				audio_size_up_playing = false
	else:
		if audio_size_down_playing:
			audio_size_down.stop()
			audio_size_down_playing = false
		if audio_size_up_playing:
			audio_size_up.stop()
			audio_size_up_playing = false
		
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
		
	if Input.is_action_pressed("size_up"): 
		print("false: ", false_count, ", true: ", true_count)	
	
