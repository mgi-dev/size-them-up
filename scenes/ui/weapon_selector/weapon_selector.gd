extends Sprite2D

var resize_modes = [
	Enums.RESIZE_MODE.ALL,
	Enums.RESIZE_MODE.HORIZONTAL,
	Enums.RESIZE_MODE.VERTICAL,
]

var resize_mode_textures = {
	Enums.RESIZE_MODE.ALL: load("res://assets/images/gun_selector/full_selector.png"),
	Enums.RESIZE_MODE.HORIZONTAL: load("res://assets/images/gun_selector/horizontal_selector.png"),
	Enums.RESIZE_MODE.VERTICAL: load("res://assets/images/gun_selector/vertical_selector.png"),
}



# Called when the node enters the scene tree for the first time.
func _ready():
	set_weapon_selector_texture()
	
	
	
func set_weapon_selector_texture():
	if GameState.multi_resize_mode_enabled:
		texture = resize_mode_textures[GameState.current_resize_mode]
	else:
		texture = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event.is_action_pressed("change_resize_mode"):
		var next_index = resize_modes.find(GameState.current_resize_mode) + 1
		print(next_index)
		if next_index == 3:
			next_index = 0
			
		SignalBus.resize_mode_selected.emit(resize_modes[next_index])
		set_weapon_selector_texture()
		
