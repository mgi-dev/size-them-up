extends RigidBody2D

class_name Resizable 

@export var sprite: Sprite2D
@export var hitbox: CollisionShape2D
@export var collision_detector: QuadriDetector
@export var ignore_collision_for: Node2D

var PIXEL_PER_STEP: float = 0.5
var PERCENT_PER_STEP: float = 0.01

var initial_size: Vector2
var initial_scale_transform: Vector2 # (2, 2) 

var current_scale_muliplier_vector = Vector2(1.0, 1.0)
var new_scale_muliplier_vector = Vector2(1.0, 1.0)

# UI is seperated from physics, need it's own var for now.
var current_sprite_scale_multiplier_vector : Vector2 = Vector2(1.0, 1.0)


"""
ADR
shape cast 2D usage for player detection instead of area 2D
when scaling area with float, detection area can becomes 10 times bigger than the Poule.
raycast allow for hardcoded target positioning. only work for top edge though. Need to extract the detector into 4 raycast working together.
no need for now, will see later if it become mandatory.
"""


func _ready() -> void:
	# storing size allow to start with various size for component. else will default to (1, 1)
	# why storing size ? keeping the original size allow to apply bigger and bigger scaling on a base value.
	# this keep the transformation linear. If we apply the transformation on scale at each frame the transformation is logarithmic. And that's bad.
	# setting size for hitbox based on parent transfom scale (1.5, 1.5)
	initial_scale_transform = scale
	sprite.scale = initial_scale_transform
	hitbox.scale = initial_scale_transform
	initial_size = sprite.texture.get_size() * sprite.scale
	

	if collision_detector:
		collision_detector.ignore(self)
		if ignore_collision_for:
			collision_detector.ignore(ignore_collision_for)

	
	SignalBus.resize_ray_resize_up.connect(resize_up)
	SignalBus.resize_ray_resize_down.connect(resize_down)
	
	parametrize_sprite_shader()


func debug():
	print(position, sprite.position, sprite.scale, hitbox.position)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_sprite_resize()


func _physics_process(delta: float) -> void:
	# called 60 times per second. do not lag this.	
	process_hitbox_resize()
	

func resize_up(target: CollisionShape2D, resize_mode: Enums.RESIZE_MODE) -> void:
	if target == hitbox:
		if can_size_up(resize_mode):
			size_up(resize_mode)


func resize_down(target: CollisionShape2D, resize_mode: Enums.RESIZE_MODE) -> void:		
	if target == hitbox:
		if can_size_down(resize_mode):
			size_down(resize_mode)


func can_size_up(resize_mode: Enums.RESIZE_MODE) -> bool:
	return GameState.can_size_up() and !is_player_colliding(resize_mode) and !is_shape_blocked(resize_mode)
	
	
func can_size_down(resize_mode: Enums.RESIZE_MODE) -> bool:
	var actual_size = get_size()
	var x_min_reached = actual_size.x <= 8
	var y_min_reached = actual_size.y <= 8
	var obj_min_size_reached
	
	if resize_mode == Enums.RESIZE_MODE.HORIZONTAL:
		obj_min_size_reached = x_min_reached
	elif resize_mode == Enums.RESIZE_MODE.VERTICAL:
		obj_min_size_reached = y_min_reached
	else:
		obj_min_size_reached = x_min_reached or y_min_reached
	# why check player whn sizing down ?
	#return GameState.can_size_down() and !is_player_colliding(resize_mode) and !obj_min_size_reached
	return GameState.can_size_down() and !obj_min_size_reached


func size_up(resize_mode: Enums.RESIZE_MODE) -> void:
	new_scale_muliplier_vector = current_scale_muliplier_vector + get_transformation_vector(resize_mode)
	emit_resized_event(resize_mode, PERCENT_PER_STEP)	
	


func size_down(resize_mode: Enums.RESIZE_MODE) -> void:
	new_scale_muliplier_vector = current_scale_muliplier_vector - get_transformation_vector(resize_mode)
	emit_resized_event(resize_mode, -PERCENT_PER_STEP)	
		
		
func emit_resized_event(resize_mode: Enums.RESIZE_MODE, chunk_resized: float):
	if resize_mode == Enums.RESIZE_MODE.ALL:
		SignalBus.resized.emit(chunk_resized * 2)
	else:
		SignalBus.resized.emit(chunk_resized)


func get_transformation_vector(resize_mode: Enums.RESIZE_MODE) -> Vector2:
	# Get the vector to apply to the chape depending on resize mode.
	var scale_x = PIXEL_PER_STEP / initial_size[0]
	var scale_y = PIXEL_PER_STEP / initial_size[1]
	
	if resize_mode == Enums.RESIZE_MODE.ALL:
		return Vector2(scale_x, scale_y)
	elif resize_mode == Enums.RESIZE_MODE.HORIZONTAL:
		return  Vector2(scale_x, 0.0)
	elif resize_mode == Enums.RESIZE_MODE.VERTICAL:
		return Vector2(0.0, scale_y)
	else: 
		return Vector2(scale_x, scale_y)
	
	
func process_hitbox_resize() -> void:
	if new_scale_muliplier_vector != current_scale_muliplier_vector:
		if new_scale_muliplier_vector < current_scale_muliplier_vector:
			# when sizing down, thing become woobly wibly when in contact with other phycical object, freeze reduce this. And add a super cool effect.
			freeze = true
		else:
			freeze = false
		hitbox.scale = initial_scale_transform * new_scale_muliplier_vector
		
		current_scale_muliplier_vector = new_scale_muliplier_vector
	else:
		freeze = false
	
	
func process_sprite_resize() -> void:
	var vector_diff = current_sprite_scale_multiplier_vector - new_scale_muliplier_vector
	if abs(vector_diff.x) > 0 or abs(vector_diff.y) > 0:
		sprite.scale = initial_scale_transform * new_scale_muliplier_vector
		current_sprite_scale_multiplier_vector = new_scale_muliplier_vector


func is_player_colliding(resize_mode: Enums.RESIZE_MODE):
	if collision_detector:
		if collision_detector.is_player_colliding() and collision_detector.is_shape_blocked(resize_mode):
			SignalBus.game_event_happened.emit(Enums.GAME_EVENT.PLAYER_CLOSE_TO_RESIZABLE)
			return true
		return false

		
func is_shape_blocked(resize_mode: Enums.RESIZE_MODE):
	if collision_detector:
		return collision_detector.is_shape_blocked(resize_mode)
	return false

func get_size() -> Vector2:
	return sprite.texture.get_size() * sprite.scale

func parametrize_sprite_shader() -> void:
	var gradiant_config = {
		Enums.RESIZE_MODE.HORIZONTAL: 0,
		Enums.RESIZE_MODE.VERTICAL: 1,
		Enums.RESIZE_MODE.ALL: 2,
	}
	sprite.material = sprite.material.duplicate()
	# What to do with this shader ? dynamic change ? link current resize to component ?
	sprite.material.set_shader_parameter("mode", 2)
