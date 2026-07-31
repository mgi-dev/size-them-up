extends Node2D

@onready var left_detector = $LeftArea2D
@onready var right_detector = $RightArea2D

var target_rotation = rotation
var min_rotato = -20
var max_rotato = 20
var rotato_speed = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_target_rotation()	
	apply_rotate_tick(delta)


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
	

func get_area_sum(colliders: Array[Node2D]) -> float:
	var total = 0.0
	for collider in colliders:
		total += collider.hitbox.shape.size.x * collider.hitbox.scale.x
		total += collider.hitbox.shape.size.y * collider.hitbox.scale.y
	return total

func get_colliders(detector: Area2D) -> Array[Node2D]:
	return detector.get_overlapping_bodies().filter(
		func(collider): return collider != self and collider is RigidBody2D
)
