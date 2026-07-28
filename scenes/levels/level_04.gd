extends Node2D

var bloc_scene = preload("res://scenes/resizable/rect_resizable.tscn")
@export var bloc_spawner: Marker2D

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.multi_resize_mode_changed.emit(true)
	add_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func add_timer():
	var timer = Timer.new()
	timer.wait_time = 4.0
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(spawn_bloc)
	add_child(timer)


func spawn_bloc():
	var obj = bloc_scene.instantiate()
	obj.global_position = bloc_spawner.position
	get_tree().current_scene.add_child(obj)
	
	# remove object after some time (out of screen).
	var timer = Timer.new()
	timer.wait_time = 30.0
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(func(): obj.queue_free())
	add_child(timer)
