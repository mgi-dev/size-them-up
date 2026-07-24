extends Node2D

@onready var gauge = $ProgressBar
@onready var particles = $GPUParticles2D

@export var max_value = 2.0
@export var min_value = 0.0

@export var start_value = 0.0


func _ready():
	SignalBus.resized.connect(fill_the_gauge)
	SignalBus.resize_ray_resize_up.connect(trigger_particles_up)
	SignalBus.resize_ray_resize_down.connect(trigger_particles_down)
	
	gauge.min_value = min_value
	gauge.max_value = max_value
	gauge.value = start_value
	gauge.step = 0.005
	SignalBus.gauge_changed.emit(to_percentage(gauge.value))


func fill_the_gauge(amount: float):
	if amount > 0:
		# shape has been sized up, draining the gauge.
		gauge.value -= abs(amount)
		change_gauge_style()
	elif amount < 0:
		# shape has been sized down, filling the gauge.
		gauge.value += abs(amount)
		change_gauge_style()
	SignalBus.gauge_changed.emit(to_percentage(gauge.value))

func trigger_particles_up(_unuzed, _kepassa):
	if gauge.value == min_value:
		print("here")
		trigger_particles(Color(0.0, 0.0, 0.867, 1.0))

func trigger_particles_down(_unuzed, _kepassa):
	if gauge.value == max_value:
		print("there")
		trigger_particles(Color(0.829, 0.0, 0.0, 1.0))


func trigger_particles(color: Color):
	print("coucou")
	if !particles.emitting:
		particles.process_material.color = color
		particles.emitting = true
		await get_tree().create_timer(0.5).timeout
		particles.emitting = false
		print("Eh beh on est pas mal.")
	
func change_gauge_style():
	
	var bg := gauge.get_theme_stylebox("background").duplicate() as StyleBoxFlat
	bg.set_border_width_all(2)
	
	var t = gauge.value / gauge.max_value
	var new_color = Color(0.0, 0.0, 0.867, 1.0).lerp(Color(0.829, 0.0, 0.0, 1.0), t)
	
	bg.border_color = new_color

	gauge.add_theme_stylebox_override("background", bg)
	
	bg.border_color = new_color

	gauge.add_theme_stylebox_override("background", bg)
	
	var fill = gauge.get_theme_stylebox("fill").duplicate()
	fill.bg_color = new_color
	gauge.add_theme_stylebox_override("fill", fill)
	
	
func to_percentage(value: float) -> float:
	return value * 100 / max_value
