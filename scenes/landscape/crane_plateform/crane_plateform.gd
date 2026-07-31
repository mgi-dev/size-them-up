extends Node2D

class_name CranePlateform

@onready var left_detector = $LeftArea2D
@onready var right_detector = $RightArea2D


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
	var left_colliders = get_colliders(left_detector)
	var right_colliders = get_colliders(right_detector)
	
	var left_area = get_area_sum(left_colliders)
	var right_area = get_area_sum(right_colliders)
	
	var total_area = left_area + right_area
	
	var left_ratio = left_area / total_area  # 0.0 to 1.0
	var right_ratio = right_area / total_area
	
	
	if left_ratio > 0.5:
		var _target_rotation = remap(left_ratio, 0.5, 1.0, 0.0, min_rotato)
		target_rotation = deg_to_rad(_target_rotation)
	elif right_ratio > 0.5:
		var _target_rotation = remap(right_ratio, 0.5, 1.0, 0.0, max_rotato)
		target_rotation = deg_to_rad(_target_rotation)
	elif right_ratio == left_ratio:
		target_rotation = deg_to_rad(0.0)


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
			print("Well , so you're a dinosaure ?")
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
		left_colliders_registry[collider] = 60
	elif detector == right_detector:
		right_colliders_registry[collider] = 60
			


func clean_colliders_registries():
	clean_colliders_registry(left_colliders_registry)
	clean_colliders_registry(right_colliders_registry)


func clean_colliders_registry(registry):
	var to_delete = []
	for key in registry:
		registry[key] -= 1
		if registry[key] <= 0:
			to_delete = []

	for element in to_delete:
		registry.erase(element)
