extends Node2D

class_name QuadriDetector

@onready var top_detector = $TopShapeCast2D
@onready var bottom_detector = $BottomShapeCast2D
@onready var right_detector = $RightShapeCast2D
@onready var left_detector = $LeftShapeCast2D

@onready var all_detector = [top_detector, bottom_detector, right_detector, left_detector]

@onready var ignore_list = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func ignore(to_ignore):
	ignore_list.append(to_ignore)


func is_shape_blocked(resize_mode: Enums.RESIZE_MODE) -> bool:
	if resize_mode in [Enums.RESIZE_MODE.VERTICAL, Enums.RESIZE_MODE.ALL]:
		if is_something_colliding(top_detector) and is_something_colliding(bottom_detector):
			return true
	if resize_mode in [Enums.RESIZE_MODE.HORIZONTAL, Enums.RESIZE_MODE.ALL]:
		if is_something_colliding(left_detector) and is_something_colliding(right_detector):
			return true
	return false


func is_something_colliding(detector: ShapeCast2D) -> bool:
	for i in range(detector.get_collision_count()):
		var collider = detector.get_collider(i)
		if collider not in ignore_list:
			print(collider, ignore, collider not in ignore_list)
			
			return true
	return false

		
func is_player_colliding()-> bool:
	for detector in all_detector:
		for i in range(detector.get_collision_count()):
			var collider = detector.get_collider(i)
			if collider is Player:
				return true
	return false
