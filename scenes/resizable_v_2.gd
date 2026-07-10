extends RigidBody2D

@onready var sprite: Polygon2D = $Polygon2D
@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var mouse_detector: CollisionShape2D = $MouseDedector/MouseDetectorCollisionShape



	
	
var RESIZE_SPEED = 0.01

var current_scale: float = 1.0
var new_scale : float = 1.0
var current_sprite_scale : float = 1.0

var selected : bool = false

var _default_size: Vector2
var _default_mouse_detector_size: Vector2

func _ready() -> void:
	# dedup allow to resizeonly one box. collision shapes are shared are shared ressources by default.
	hitbox.shape = hitbox.shape.duplicate(true)
	var shape := hitbox.shape
	# storing size allow to start with various size for component. else will default to (1, 1)
	_default_size = shape.size
	
	mouse_detector.shape = mouse_detector.shape.duplicate(true)
	var shape_2 := mouse_detector.shape
	_default_mouse_detector_size = shape_2.size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# called every now and then, for display, animations, etc.
	
	if abs(current_sprite_scale - new_scale) >= RESIZE_SPEED:
		process_sprite_resize()
		
		
func _physics_process(delta: float) -> void:
	# called 60 times per second. do not lag this.
	if Input.is_action_pressed("size_up"):	
		size_up()
		process_hitbox_resize()
		process_mouse_detector_resize()

		
	elif Input.is_action_pressed("size_down"):
		size_down()
		process_hitbox_resize()
		process_mouse_detector_resize()

func can_size_up() -> bool:
	return selected and GameState.can_size_up()
	
	
func can_size_down() -> bool:
	return selected and GameState.can_size_down()

func size_up() -> void:
	if can_size_up():
		new_scale = current_scale + RESIZE_SPEED
		SignalBus.resized.emit(new_scale - current_scale)
	
func size_down() -> void:
	if can_size_down():
		new_scale = current_scale - RESIZE_SPEED
		SignalBus.resized.emit(new_scale - current_scale)
	
	
func process_hitbox_resize() -> void:
	var shape := hitbox.shape
	shape.size = _default_size * new_scale
	current_scale = new_scale

func process_mouse_detector_resize() -> void:
	var shape := mouse_detector.shape
	shape.size = _default_mouse_detector_size * new_scale


func process_sprite_resize() -> void:
	sprite.scale = Vector2.ONE * new_scale
	
func _on_mouse_dedector_mouse_entered():
	selected = true


func _on_mouse_dedector_mouse_exited():
	selected = false
