extends Node2D

@export var is_flashing: bool = true


@export var flashing_polygon: Polygon2D
@export var color_1 = Color("00c6c6")
@export var color_2 = Color("372f47")

# Called when the node enters the scene tree for the first time.
func _ready():
	flashing()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func flashing(): 
	if is_flashing:
		flashing_polygon.color = color_1
		await get_tree().create_timer(0.5).timeout
		flashing_polygon.color = color_2
		await get_tree().create_timer(0.5).timeout
		flashing()
