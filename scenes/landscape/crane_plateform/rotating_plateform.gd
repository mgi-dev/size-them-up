extends Node2D

class_name RotatingPlateform

@onready var left_detector: Area2D = $LeftArea2D
@onready var right_detector = $RightArea2D
@export var debug = false

var left_colliders_registry: Dictionary[Node2D, int] = {}
var right_colliders_registry: Dictionary[Node2D, int] = {}

var target_rotation = rotation
var min_rotato = -20
var max_rotato = 20
var rotato_speed = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	populate_colliders_registries()
	set_target_rotation()
	apply_rotate_tick(delta)
	clean_colliders_registries()


func apply_rotate_tick(delta):
	if target_rotation == rotation:
		return
	rotation = lerp(rotation, target_rotation, rotato_speed * delta)
		

func set_target_rotation():
	var left_area = get_area_sum(get_colliders(left_detector))
	var right_area = get_area_sum(get_colliders(right_detector))
	get_intersecting_area_sum(left_detector, get_colliders(left_detector))
	
	var area_needed_per_degree = 20.0
	var unbalanced_right = right_area - left_area

	var degres_to_right = unbalanced_right / area_needed_per_degree
	# no clamp ?
	target_rotation = deg_to_rad(degres_to_right)

func get_intersecting_area_sum(detector: Area2D, colliders: Array):
	return

	for collider in colliders:

		print(Geometry2D.intersect_polygons(
			detector.get_node("CollisionShape2D").polygon, collider.get_polygon())
		)

func get_area_sum(colliders: Array[Node2D]) -> float:
	var total = 0.0
	
	for collider in colliders:
		if collider is Resizable:
			total += collider.hitbox.shape.size.x * collider.hitbox.scale.x
			total += collider.hitbox.shape.size.y * collider.hitbox.scale.y
		elif collider is Box:
			total += collider.collision_shape.shape.size.x * collider.scale.x
			total += collider.collision_shape.shape.size.y * collider.scale.y
		else:
			print("Unknown Collider in RotatingPlateform.")
	return total


func get_colliders(detector: Area2D) -> Array[Node2D]:
	if detector == left_detector:
		return left_colliders_registry.keys()
	if detector == right_detector:
		return right_colliders_registry.keys()
	else:
		return []


func is_collider_on_plateform(collider, ignored_collider):
	# or on an object touching the plateform.
	for _collider in collider.contacts:
		if _collider == self: # is on plateform
			return true
		
		if not is_on_white_list(_collider):
			continue
		
		if _collider == ignored_collider:
			# to avoid recusrsive detection (oupsy !)
			continue
		
		if is_collider_on_plateform(_collider, collider):
			return true
	
	return false


func populate_colliders_registries():
	populate_colliders_registry(left_detector)
	populate_colliders_registry(right_detector)


func is_on_white_list(object) -> bool:
	if object is RigidBody2D: return true
	
	return false

func populate_colliders_registry(detector):
	var colliders = []
	for _collider in detector.get_overlapping_bodies():
		if is_on_white_list(_collider):
			colliders.append(_collider)
	
	for _collider in colliders:
		if is_collider_on_plateform(_collider, _collider):
			add_to_colliders_registry(detector, _collider)


func add_to_colliders_registry(detector, collider):
	if detector == left_detector:
		left_colliders_registry[collider] = 30
	elif detector == right_detector:
		right_colliders_registry[collider] = 30
			


func clean_colliders_registries():
	clean_colliders_registry(left_colliders_registry)
	clean_colliders_registry(right_colliders_registry)


func clean_colliders_registry(registry):
	# To avoid flicking when rotating, objets area considered in contact for about half a second
	# even when no contact is detected anymore.
	var to_delete = []
	for key in registry:
		registry[key] -= 1
		if registry[key] <= 0:
			to_delete.append(key)

	for element in to_delete:
		registry.erase(element)



# many small detector with fix area ?
#
