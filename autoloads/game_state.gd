extends Node

# values are true by default to allow scaling in debug mode.
# if a gauge is present in the scene it will send 0 on_ready()
var god_mode: bool = false
var _can_size_up: bool = true
var _can_size_down: bool = true
var current_resize_mode: Enums.RESIZE_MODE = Enums.RESIZE_MODE.ALL
var multi_resize_mode_enabled: bool = false


func _ready():
	SignalBus.gauge_changed.connect(on_gauge_changed)
	SignalBus.resize_mode_selected.connect(on_resize_mode_changed)
	SignalBus.multi_resize_mode_changed.connect(func(enabled): multi_resize_mode_enabled=enabled)
	
	

func _physics_process(delta):
	if Input.is_action_just_pressed("toggle_god_mode"):
		god_mode = !god_mode
		multi_resize_mode_enabled = !multi_resize_mode_enabled
		
		print("god mode is ", "on" if god_mode else "off")


func on_gauge_changed(percentage: float) -> void:
	if percentage >= 100:
		_can_size_up = true
		_can_size_down = false
	elif percentage <= 0:
		_can_size_up = false
		_can_size_down = true
	else:
		_can_size_up = true
		_can_size_down = true

func on_resize_mode_changed(resize_mode: Enums.RESIZE_MODE):
	if multi_resize_mode_enabled:
		current_resize_mode = resize_mode


func can_size_up() -> bool:
	if god_mode:
		return true
	if _can_size_up:
		return true
	else:
		SignalBus.game_event_happened.emit(Enums.GAME_EVENT.EMPTY_GAUGE)
	return false
	
	
func can_size_down() -> bool:
	if god_mode:
		return true
	if _can_size_down:
		return true
	else:
		SignalBus.game_event_happened.emit(Enums.GAME_EVENT.FULL_GAUGE)
	return false
