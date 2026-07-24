extends RayCast2D

class_name ResizeRay


@onready var visible_laser = $Line2D

@onready var laser_width: float
@onready var laser_color: Color
@onready var resize : Enums.RESIZE = Enums.RESIZE.UP

@onready var size_up_color: Color = Color(0.856, 0.002, 0.001, 1.0)
@onready var size_down_color: Color = Color(0.108, 0.345, 1.0, 1.0)

@onready var beam_particles: GPUParticles2D = $BeamParticles2D

var sub_ray = false

var is_resizing_laser_enabled: bool = false



func _ready():
	visible_laser.width = 0.0
	
	for node in get_tree().get_nodes_in_group(Enums.CLIMBABLE_GROUP):
		if node is CollisionObject2D:
			add_exception(node)
	# avoid sharing ressource.
	beam_particles.process_material = beam_particles.process_material.duplicate()
	
	
func _process(delta):		
	handle_colliding(delta)
	size_up_beam_particle()
	

func _physics_process(delta):
	pass
	


func set_ray_position(start: Vector2, end: Vector2):
	position = start
	target_position = end
	force_raycast_update()
	

func set_visible_laser_properties(_laser_width, _resize, _particle_emiting):
	if _laser_width != null:	
		laser_width = _laser_width
		visible_laser.width = _laser_width
	
	if _resize != null:
		resize = _resize
		if resize == Enums.RESIZE.UP:
			laser_color = size_up_color
		else:
			laser_color = size_down_color
		visible_laser.modulate = laser_color
	
	if _particle_emiting != null:
		beam_particles.emitting = _particle_emiting
		
		
func enable_laser():
	is_resizing_laser_enabled = true


func disable_laser():
	is_resizing_laser_enabled = false


func handle_colliding(delta):
	visible_laser.set_point_position(1, target_position)
	if is_colliding():
		# repositionning after colliding miss the collision in some weird angles.
		# manually ajusting of one pixel...
		var bloup = (to_local(get_collision_point()) - position).normalized()
		target_position = to_local(get_collision_point()) + bloup
		
		if is_resizing_laser_enabled and is_target_resizable():
			get_parent().laser_hit_resizable(get_collision_shape())
		
		if is_target_reflector():
			get_parent().laser_hit_reflector(self, get_collision_shape())
		else:
			get_parent().laser_leaved_reflector(self)
			
		visible_laser.set_point_position(1, target_position)
		force_raycast_update()
	else:
		get_parent().laser_leaved_reflector(self)


func size_up_beam_particle():
	if is_resizing_laser_enabled:
		var center = visible_laser.points[0].lerp(visible_laser.points[1], 0.5)
		beam_particles.position = center
		
		beam_particles.process_material.emission_box_extents = Vector3(
			visible_laser.points[0].distance_to(visible_laser.points[1]) / 2,
			beam_particles.process_material.emission_box_extents.y,
			beam_particles.process_material.emission_box_extents.z
			)
		beam_particles.rotation = Vector2.RIGHT.angle_to(target_position)
		if resize == Enums.RESIZE.UP:
			beam_particles.modulate = Color(0.856, 0.002, 0.001, 1.0)
			beam_particles.process_material.initial_velocity_min = 0 + abs(beam_particles.process_material.initial_velocity_min)
			beam_particles.process_material.initial_velocity_max = 0 + abs(beam_particles.process_material.initial_velocity_max)
		else:
			beam_particles.modulate = Color(0.108, 0.345, 1.0, 1.0)
			beam_particles.process_material.initial_velocity_min = 0 - abs(beam_particles.process_material.initial_velocity_min)
			beam_particles.process_material.initial_velocity_max = 0 - abs(beam_particles.process_material.initial_velocity_max)

	
func is_target_resizable() -> bool:
	if is_colliding():
		var collider = get_collider()
		return collider is Resizable
	return false


func is_target_reflector()-> bool:
	var collider = get_collider()
	return collider is Reflector

		
func get_collision_shape() -> CollisionShape2D:
	var collider = get_collider()
	var shape_index = get_collider_shape()
	var owner_id = collider.shape_find_owner(shape_index)
	return collider.shape_owner_get_owner(owner_id)
