extends RigidBody2D
# AnimatableBody2D
class_name Resizable 

@export var sprite: Sprite2D
@export var hitbox: CollisionShape2D
@export var player_detector: ShapeCast2D


enum RESIZE_MODE {ALL, VERTICAL, HORIZONTAL}

@export var resize_mode: RESIZE_MODE = RESIZE_MODE.ALL

var RESIZE_SPEED: float = 0.01

var initial_scale_transform: Vector2 # (2, 2) 

var current_scale_muliplier: float = 1.0
var new_scale_multiplier : float = 1.0
# UI is seperated from physics, need it's own var for now.
var current_sprite_scale_multiplier : float = 1.0


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
	# TODO: actually useless, see later
	# setting size for hitbox based on parent transfom scale (1.5, 1.5)
	initial_scale_transform = scale
	
	sprite.scale = initial_scale_transform
	hitbox.scale = initial_scale_transform
	if player_detector:
		player_detector.target_position.y = hitbox.position.y + 5
		player_detector.force_shapecast_update()
	
	SignalBus.resize_ray_resize_up.connect(resize_up)
	SignalBus.resize_ray_resize_down.connect(resize_down)
	
	parametrize_sprite_shader()


func debug():
	print(position, sprite.position, sprite.scale, hitbox.position)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# called every now and then, for display, animations, etc.
	# print(RESIZE_SPEED)
	if abs(current_sprite_scale_multiplier - new_scale_multiplier) >= RESIZE_SPEED:
		process_sprite_resize()


func _physics_process(delta: float) -> void:
	# called 60 times per second. do not lag this.	
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
	return GameState.can_size_up() and !is_player_colliding()
	
	
func can_size_down() -> bool:
	return GameState.can_size_down() and !is_player_colliding()


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
	if new_scale_multiplier != current_scale_muliplier:
		if new_scale_multiplier < current_scale_muliplier:
			# when sizing down, thing become woobly wibly when in contact with other phycical object, freeze reduce this. And add a super cool effect.
			freeze = true
		else:
			freeze = false
		hitbox.scale = get_transformed_scale(initial_scale_transform, new_scale_multiplier)
		if player_detector:
			player_detector.target_position.y = hitbox.position.y + 5
			player_detector.force_shapecast_update()
		current_scale_muliplier = new_scale_multiplier
	else:
		freeze = false


func process_sprite_resize() -> void:
	sprite.scale = get_transformed_scale(initial_scale_transform, new_scale_multiplier)
	current_sprite_scale_multiplier = new_scale_multiplier


func is_player_colliding():
	if not player_detector:
		return false
	for i in range(player_detector.get_collision_count()):
		var collider = player_detector.get_collider(i)
		if collider is Player:
			SignalBus.game_event_happened.emit(Enums.GAME_EVENT.PLAYER_CLOSE_TO_RESIZABLE)
			return true
	return false
	
	
func parametrize_sprite_shader() -> void:
	var gradiant_config = {
		RESIZE_MODE.HORIZONTAL: 0,
		RESIZE_MODE.VERTICAL: 1,
		RESIZE_MODE.ALL: 2,
	}
	sprite.material = sprite.material.duplicate()
	sprite.material.set_shader_parameter("mode", gradiant_config[resize_mode])
