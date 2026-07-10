extends RigidBody2D

@export var sprite: Polygon2D
@export var hitbox: CollisionShape2D
@export var mouse_detector: CollisionShape2D


enum RESIZE_MODE {ALL, VERTICAL, HORIZONTAL}

@export var resize_mode: RESIZE_MODE = RESIZE_MODE.ALL

var RESIZE_SPEED: float = 0.01

var initial_scale_transform: Vector2 # (2, 2) 
var initial_size: Vector2 # (56, 56) 

var current_scale_muliplier: float = 1.0
var new_scale_multiplier : float = 1.0
# UI is seperated from physics, need it's own var for now.
var current_sprite_scale_multiplier : float = 1.0

var selected : bool = false


func _ready() -> void:
	# storing size allow to start with various size for component. else will default to (1, 1)
	initial_size = hitbox.shape.size * scale
	
	# setting size for hitbox based on parent transfom scale (1.5, 1.5)
	initial_scale_transform = scale
	sprite.scale = initial_scale_transform
	hitbox.scale = initial_scale_transform
	mouse_detector.scale = initial_scale_transform


func debug():
	print(position, sprite.position, sprite.scale, hitbox.position, hitbox.shape.size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# called every now and then, for display, animations, etc.
	# print(RESIZE_SPEED)
	if abs(current_sprite_scale_multiplier - new_scale_multiplier) >= RESIZE_SPEED:
		process_sprite_resize()


func _physics_process(delta: float) -> void:
	# called 60 times per second. do not lag this.
	if Input.is_action_pressed("size_up"):	
		if can_size_up():
			size_up()
			process_hitbox_resize()
			process_mouse_detector_resize()
		if selected:
			# debug()
			pass
		
	elif Input.is_action_pressed("size_down"):
		if can_size_down():
			size_down()
			process_hitbox_resize()
			process_mouse_detector_resize()

func can_size_up() -> bool:
	return selected and GameState.can_size_up()
	
	
func can_size_down() -> bool:
	return selected and GameState.can_size_down()


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


func process_mouse_detector_resize() -> void:
	mouse_detector.scale = get_transformed_scale(initial_scale_transform, new_scale_multiplier)


func process_sprite_resize() -> void:
	sprite.scale = get_transformed_scale(initial_scale_transform, new_scale_multiplier)
	current_sprite_scale_multiplier = new_scale_multiplier
	
	
func _on_mouse_dedector_mouse_entered():
	print("entered")
	selected = true


func _on_mouse_dedector_mouse_exited():
	print("pas entered")
	selected = false
