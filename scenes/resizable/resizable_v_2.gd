extends RigidBody2D

class_name Resizable 

@export var sprite: Polygon2D
@export var hitbox: CollisionShape2D


enum RESIZE_MODE {ALL, VERTICAL, HORIZONTAL}

@export var resize_mode: RESIZE_MODE = RESIZE_MODE.ALL

var RESIZE_SPEED: float = 0.01

var initial_scale_transform: Vector2 # (2, 2) 
var initial_size: Vector2 # (56, 56) 

var current_scale_muliplier: float = 1.0
var new_scale_multiplier : float = 1.0
# UI is seperated from physics, need it's own var for now.
var current_sprite_scale_multiplier : float = 1.0


func _ready() -> void:
	# storing size allow to start with various size for component. else will default to (1, 1)
	# why storing size ? keeping the original size allow to apply bigger and bigger scaling on a base value.
	# this keep the transformation linear. If we apply the transformation on scale at each frame the transformation is logarithmic. And that's bad.
	initial_size = hitbox.shape.get_rect().size * scale
	# setting size for hitbox based on parent transfom scale (1.5, 1.5)
	initial_scale_transform = scale
	
	sprite.scale = initial_scale_transform
	hitbox.scale = initial_scale_transform
	
	SignalBus.resize_ray_resize_up.connect(resize_up)
	SignalBus.resize_ray_resize_down.connect(resize_down)


func debug():
	print("selected : ", hitbox == GameState.resize_ray_target , " ", position, sprite.position, sprite.scale, hitbox.position)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# called every now and then, for display, animations, etc.
	# print(RESIZE_SPEED)
	if abs(current_sprite_scale_multiplier - new_scale_multiplier) >= RESIZE_SPEED:
		process_sprite_resize()


func _physics_process(delta: float) -> void:
	# called 60 times per second. do not lag this.	
	pre_process_resize()
	process_hitbox_resize()

func resize_up(target: CollisionShape2D) -> void:
	if target == hitbox:
		if can_size_up():
			size_up()
			#process_hitbox_resize()


func resize_down(target: CollisionShape2D) -> void:		
	if target == hitbox:
		if can_size_down():
			size_down()
			#process_hitbox_resize()


func can_size_up() -> bool:
	return GameState.can_size_up()
	
	
func can_size_down() -> bool:
	return GameState.can_size_down()


func size_up() -> void:
	new_scale_multiplier = current_scale_muliplier + RESIZE_SPEED
	SignalBus.resized.emit(new_scale_multiplier - current_scale_muliplier)
	
	
func size_down() -> void:
	new_scale_multiplier = current_scale_muliplier - RESIZE_SPEED
	SignalBus.resized.emit(new_scale_multiplier - current_scale_muliplier)


func get_transformed_scale(_scale: Vector2, transform: float) -> Vector2:
	# Transform the given Vector depending on selected resize mode.
	if resize_mode == RESIZE_MODE.ALL:
		return _scale * transform
	if resize_mode == RESIZE_MODE.HORIZONTAL:
		return Vector2(_scale.x * transform, _scale.y)
	if resize_mode == RESIZE_MODE.VERTICAL:
		return Vector2(_scale.x, _scale.y * transform)
	else: 
		return _scale * transform

	
func process_hitbox_resize() -> void:
	hitbox.scale = get_transformed_scale(initial_scale_transform, new_scale_multiplier)
	current_scale_muliplier = new_scale_multiplier


func process_sprite_resize() -> void:
	sprite.scale = get_transformed_scale(initial_scale_transform, new_scale_multiplier)
	current_sprite_scale_multiplier = new_scale_multiplier


func pre_process_resize()-> void:
	# this allow to stabilizible resizable when player is on top.
	# not perfect, do the job for now.
	for colliding_body in get_colliding_bodies():
		if colliding_body is Player:
			if to_local(colliding_body.position).y < hitbox.position.y:
				var increased_size = (
					initial_size * get_transformed_scale(
						initial_scale_transform, 
						new_scale_multiplier
					) - initial_size * get_transformed_scale(
						initial_scale_transform, 
						current_scale_muliplier
					)
				).y
				colliding_body.position.y -= increased_size.y + 0.3
