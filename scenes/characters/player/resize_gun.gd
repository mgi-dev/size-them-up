extends Node2D

class_name ResizeGun

@onready var state_machine: StateMachine

@onready var resize_ray = $ResizeRay
@onready var casting_particles: GPUParticles2D = $CastingParticles2D

@onready var sound_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_size_down : AudioStreamPlayer2D = $AudioSizeDown
@onready var audio_size_up : AudioStreamPlayer2D = $AudioSizeUp

@onready var visible_laser_width = 0.0
@export var laser_min_width: float = 0.0
@export var laser_max_width: float = 4.0
@export var laser_ready_speed: float = 0.1

var resize_mode = Enums.RESIZE_MODE.ALL


class LaserState extends State:
	
	var resize_gun: ResizeGun
	
	func _init(_resize_gun):
		resize_gun = _resize_gun
	
	
	func increase_laser_size():
		resize_gun.visible_laser_width = move_toward(
			resize_gun.visible_laser_width,
			resize_gun.laser_max_width,
			resize_gun.laser_ready_speed
		)
	
	func get_all_lasers() -> Array[ResizeRay]:
		var lasers: Array[ResizeRay] = [resize_gun.resize_ray]
		for key in resize_gun.ray_hierarchy:
			if is_instance_valid(key):
				var sub_laser = resize_gun.ray_hierarchy[key]
				if is_instance_valid(sub_laser):
					lasers.append(sub_laser)
		return lasers
	

class LaserIdleState extends LaserState:
	func enter():
		resize_gun.sound_player.stop()
		resize_gun.casting_particles.emitting = false
		resize_gun.visible_laser_width = resize_gun.laser_min_width
		for laser in get_all_lasers():
			laser.disable_laser()
			laser.set_visible_laser_properties(resize_gun.laser_min_width, null, false)
		
		super.enter()

	func exit():
		super.exit()

	func update(delta):
		super.update(delta)
	
	func play_charging_sound():
		# disable this sound in this state.
		pass


class LaserChargingUpState extends LaserState:
	func enter():
		if !resize_gun.sound_player.is_playing():
			resize_gun.sound_player.play()
		
		resize_gun.casting_particles.modulate = Color(0.856, 0.002, 0.001, 1.0)
		resize_gun.casting_particles.emitting = true

		super.enter()

	func exit():
		super.exit()

	func update(delta):
		increase_laser_size()
		resize_gun.resize_ray.set_visible_laser_properties(resize_gun.visible_laser_width, Enums.RESIZE.UP, false)
		
		super.update(delta)
		
	
class LaserChargingDownState extends LaserState:
	func enter():
		if !resize_gun.sound_player.is_playing():
			resize_gun.sound_player.play()
		
		resize_gun.casting_particles.modulate = Color(0.108, 0.345, 1.0, 1.0)
		resize_gun.casting_particles.emitting = true
		super.enter()

	func exit():
		super.exit()

	func update(delta):
		increase_laser_size()
		resize_gun.resize_ray.set_visible_laser_properties(resize_gun.visible_laser_width, Enums.RESIZE.DOWN, false)
		super.update(delta)
		

class LaserFullyChargedUpState extends LaserState:
	func enter():
		resize_gun.audio_size_up.play()
		resize_gun.casting_particles.modulate = Color(0.856, 0.002, 0.001, 1.0)
		resize_gun.casting_particles.emitting = true
		super.enter()

	func exit():
		resize_gun.audio_size_up.stop()
		super.exit()

	func update(delta):
		for _laser in get_all_lasers():
			update_laser(_laser)
		super.update(delta)
		
	func update_laser(laser: ResizeRay):
		laser.enable_laser()
		laser.set_visible_laser_properties(resize_gun.visible_laser_width, Enums.RESIZE.UP, true)

class LaserFullyChargedDownState extends LaserState:
	func enter():
		resize_gun.audio_size_down.play()
		resize_gun.casting_particles.modulate = Color(0.108, 0.345, 1.0, 1.0)
		resize_gun.casting_particles.emitting = true
		super.enter()

	func exit():
		resize_gun.audio_size_down.stop()
		super.exit()

	func update(delta):
		for _laser in get_all_lasers():
			update_laser(_laser)
		super.update(delta)
		
	func update_laser(laser: ResizeRay):
		laser.enable_laser()
		laser.set_visible_laser_properties(resize_gun.visible_laser_width, Enums.RESIZE.DOWN, true)

		

func _ready():
	visible_laser_width = laser_min_width
	
	state_machine = StateMachine.new({
		LaserIdleState: LaserIdleState.new(self),
		LaserChargingUpState: LaserChargingUpState.new(self),
		LaserChargingDownState: LaserChargingDownState.new(self),
		LaserFullyChargedUpState: LaserFullyChargedUpState.new(self),
		LaserFullyChargedDownState: LaserFullyChargedDownState.new(self),
	})
	

func _process(delta):
	update_mouse_position()
	state_machine.set_state(get_next_state())
	state_machine.update(delta)
	clean_key_hierarchy()
	
func _physics_process(delta):
	pass
	
		
func update_mouse_position():
	var far_away_position = to_local(get_global_mouse_position()).normalized() * 5000
	resize_ray.set_ray_position(resize_ray.position, far_away_position)
	

	
func _input(event):
	select_resize_mode(event)


var resize_modes = [
	Enums.RESIZE_MODE.ALL,
	Enums.RESIZE_MODE.HORIZONTAL,
	Enums.RESIZE_MODE.VERTICAL,
]


func select_resize_mode(event):
	# trigger event if resize mode change (horizontal, etc )
	if event.is_action_pressed("change_resize_mode"):
		var next_index = resize_modes.find(GameState.current_resize_mode) + 1
		if next_index == 3:
			next_index = 0
		resize_mode = resize_modes[next_index]
		SignalBus.resize_mode_selected.emit(resize_modes[next_index])


func get_next_state() -> State:
	# select a state based on key pressed and laser width.
	if Input.is_action_pressed("size_up"):
		if visible_laser_width == laser_max_width and is_laser_hitting_resizable():
			return state_machine.states[LaserFullyChargedUpState]
		else:
			return state_machine.states[LaserChargingUpState]
	elif Input.is_action_pressed("size_down"):
		if visible_laser_width == laser_max_width and is_laser_hitting_resizable():
			return state_machine.states[LaserFullyChargedDownState]
		else:
			return state_machine.states[LaserChargingDownState]
	else:
		return state_machine.states[LaserIdleState]
	
	
func is_laser_hitting_resizable() -> bool:
	if resize_ray.is_target_resizable():
		return true
	for key in ray_hierarchy:
		if is_instance_valid(key):
			var sub_laser = ray_hierarchy[key]
			if is_instance_valid(sub_laser):
				if sub_laser.is_target_resizable():
					return true
	return false

	
func laser_hit_resizable(collision_shape):
	if state_machine.current_state is LaserFullyChargedUpState:
		SignalBus.resize_ray_resize_up.emit(collision_shape, resize_mode)
	elif state_machine.current_state is LaserFullyChargedDownState:
		SignalBus.resize_ray_resize_down.emit(collision_shape, resize_mode)
	

func get_new_laser_direction(laser, collision_shape) -> Array[Vector2]:
	var direction = laser.target_position.normalized()
	var normal = laser.get_collision_normal()
	var reflected = direction.bounce(normal)
	var unknown = laser.target_position + reflected * 5000
	
	return [to_local(laser.get_collision_point()), unknown]
	
	
var ray_hierarchy:  = {
		
}
	
	
func laser_hit_reflector(laser: ResizeRay, collision_shape):
	
	if not ray_hierarchy.get(laser):
		if ray_hierarchy.size() > 5:
			return
		# limit ray hierarchy
		const ResizeRayScene = preload("res://scenes/characters/player/resize_ray.tscn")
		ray_hierarchy[laser] = ResizeRayScene.instantiate()
		ray_hierarchy[laser].add_exception(collision_shape)
		add_child(ray_hierarchy[laser])
		ray_hierarchy[laser].tree_exited.connect(func():
			
			ray_hierarchy.erase(laser)
		)
	
	var bounced_ray = ray_hierarchy[laser]
	bounced_ray.set_visible_laser_properties(laser.laser_width, laser.resize, laser.beam_particles.emitting)
	bounced_ray.enable_laser()
	bounced_ray.sub_ray = true
	var new_direction = get_new_laser_direction(laser, collision_shape)
	bounced_ray.set_ray_position(new_direction[0], new_direction[1])
	# need state machina


func laser_leaved_reflector(laser: ResizeRay):
	if ray_hierarchy.get(laser):
		recursive_clean(laser)
	
	
func recursive_clean(laser: ResizeRay):
	if ray_hierarchy.get(laser):
		return recursive_clean(ray_hierarchy.get(laser))
	else:
		laser.queue_free()
		ray_hierarchy.erase(laser)
		return null
	
func clean_key_hierarchy():
	for key in ray_hierarchy:
		if is_instance_valid(key):
			var sub_laser = ray_hierarchy[key]
			if !is_instance_valid(sub_laser):
				if is_instance_valid(key):
					key.queue_free()
				ray_hierarchy.erase(key)
				
		if !is_instance_valid(key):
			# BIG memory leak, must keep game short i guess.
			var sub_laser = ray_hierarchy[key]
			if is_instance_valid(sub_laser):		
				sub_laser.queue_free()
			ray_hierarchy.erase(key)
