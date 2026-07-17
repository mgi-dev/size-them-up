extends RigidBody2D

class_name Resizable 

@export var sprite: Sprite2D
@export var hitbox: CollisionShape2D
@export var collision_detector: QuadriDetector


var RESIZE_SPEED: float = 0.01

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
	if collision_detector:
		collision_detector.ignore(self)

	
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
		if can_size_up():
			size_up(resize_mode)
			#process_hitbox_resize()


func resize_down(target: CollisionShape2D, resize_mode: Enums.RESIZE_MODE) -> void:		
	if target == hitbox:
		if can_size_down():
			size_down(resize_mode)
			#process_hitbox_resize()


func can_size_up() -> bool:
	return GameState.can_size_up() and !is_player_colliding() and !collision_detector.is_shape_blocked()
	
	
func can_size_down() -> bool:
	var obj_min_size_reached = current_scale_muliplier_vector.x <= 0.02 or current_scale_muliplier_vector.y <= 0.02
	return GameState.can_size_down() and !is_player_colliding() and !obj_min_size_reached


func size_up(resize_mode: Enums.RESIZE_MODE) -> void:
	var _transform = get_transformation_vector(RESIZE_SPEED, resize_mode)
	new_scale_muliplier_vector = current_scale_muliplier_vector + _transform
	emit_resized_event(current_scale_muliplier_vector, new_scale_muliplier_vector)

	
func size_down(resize_mode: Enums.RESIZE_MODE) -> void:
	var _transform = get_transformation_vector(RESIZE_SPEED, resize_mode)
	new_scale_muliplier_vector = current_scale_muliplier_vector - _transform
	emit_resized_event(current_scale_muliplier_vector, new_scale_muliplier_vector)


func emit_resized_event(current_scale_muliplier_vector: Vector2, new_scale_muliplier_vector: Vector2):
	var diff_vector = new_scale_muliplier_vector - current_scale_muliplier_vector
	SignalBus.resized.emit(diff_vector.x + diff_vector.y)


func get_transformation_vector(transform: float, resize_mode: Enums.RESIZE_MODE) -> Vector2:
	# Get the vector to apply to the chape depending on resize mode.
	if resize_mode == Enums.RESIZE_MODE.ALL:
		return  Vector2(transform, transform)
	elif resize_mode == Enums.RESIZE_MODE.HORIZONTAL:
		return  Vector2(transform, 0.0)
	elif resize_mode == Enums.RESIZE_MODE.VERTICAL:
		return Vector2(0.0, transform)
	else: 
		return Vector2(transform, transform)
	
	
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
	if abs(vector_diff.x) >= RESIZE_SPEED or abs(vector_diff.y) >= RESIZE_SPEED:
		sprite.scale = initial_scale_transform * new_scale_muliplier_vector
		current_sprite_scale_multiplier_vector = new_scale_muliplier_vector


func is_player_colliding():
	if collision_detector:
		var colliding = collision_detector.is_player_colliding()
		print(colliding)
		if colliding:
			SignalBus.game_event_happened.emit(Enums.GAME_EVENT.PLAYER_CLOSE_TO_RESIZABLE)
		return colliding
	else:
		return false


func parametrize_sprite_shader() -> void:
	var gradiant_config = {
		Enums.RESIZE_MODE.HORIZONTAL: 0,
		Enums.RESIZE_MODE.VERTICAL: 1,
		Enums.RESIZE_MODE.ALL: 2,
	}
	sprite.material = sprite.material.duplicate()
	# What to do with this shader ? dynamic change ? link current resize to component ?
	sprite.material.set_shader_parameter("mode", 2)
