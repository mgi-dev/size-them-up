extends Node2D

class_name RotatingPlateform


@onready var left_detector: Area2D = $LeftArea2D
@onready var right_detector = $RightArea2D

@onready var left_detector_grid = $LeftDetector
@onready var right_detector_grid = $RightDetector

@export var debug = false

var left_colliders_registry: Dictionary[Node2D, int] = {}
var right_colliders_registry: Dictionary[Node2D, int] = {}

var target_rotation = rotation
var min_rotato = -20
var max_rotato = 20
var rotato_speed = 0.2


""" The flow:
- populate_colliders_registries use left_detector and right detector to find overlapping bodies touching the plateform
(detectors are the two big area 2D.) Code is trash, but it works.

- Then in set_target_rotation each sub detector of detector grid check if they overlaps previously detected shape
If so we add "10.0" to detected area.

- The we compute rotation based on this numbers

Abstract:
	
- is touching plateform --> go into registry 
- Is sub detector touched by bloc in registry ? --> Yeah --> compute weight
- apply rotato.
"""

func _process(delta):
	populate_colliders_registries()
	set_target_rotation()
	apply_rotate_tick(delta)
	clean_colliders_registries()
	


func apply_rotate_tick(delta):
	if target_rotation == rotation:
		return
	rotation = move_toward(rotation, target_rotation, rotato_speed * delta)
		

func set_target_rotation():
	var intersecting_left = get_intersecting_area_sum(left_detector_grid, get_colliders(left_detector))
	var intersecting_right = get_intersecting_area_sum(right_detector_grid, get_colliders(right_detector))
	
	# edges detector could be "heavier" than center detectors :big_plan:
	var area_needed_per_degree = 30.0
	var unbalanced_right = intersecting_right - intersecting_left
	
	var degres_to_right = unbalanced_right / area_needed_per_degree
	# no clamp ? no clamp.
	target_rotation = deg_to_rad(degres_to_right)

func get_intersecting_area_sum(detector_grid: Node2D, colliders: Array) -> float:
	var total = 0.0
	for sub_detector in detector_grid.get_children():
		for _collider in sub_detector.get_overlapping_bodies():
			if _collider in colliders:
				total += 10.0
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
