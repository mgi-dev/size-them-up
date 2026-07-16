extends Sprite2D


@onready var flashing_polygon = $Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready():
	flashing_mouse()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func flashing_mouse(): 
	flashing_polygon.color = Color.RED
	await get_tree().create_timer(0.5).timeout
	flashing_polygon.color = Color.WHITE
	await get_tree().create_timer(0.5).timeout
	flashing_mouse()
