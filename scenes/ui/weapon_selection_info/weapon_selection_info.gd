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
	set_weapon_selector_texture(GameState.current_resize_mode)
	SignalBus.resize_mode_selected.connect(set_weapon_selector_texture)
	SignalBus.multi_resize_mode_changed.connect(func(_enabled): set_weapon_selector_texture(GameState.current_resize_mode))
	SignalBus.multi_resize_mode_first_enabled.connect(func(): weapon_selector_first_enable())
	
func set_weapon_selector_texture(resize_mode: Enums.RESIZE_MODE):
	if GameState.multi_resize_mode_enabled:
		texture = resize_mode_textures[resize_mode]
	else:
		texture = null


func weapon_selector_first_enable():
	var initial_position = position
	var initial_scale = scale
	var animation_duration = 1.5

	scale = Vector2(1.1, 1.1)
	position = to_local(Vector2(get_viewport().size.x / 1.5 - texture.get_size().x / 2 , get_viewport().size.y / 2 + texture.get_size().y / 2))
	
	await get_tree().create_timer(0.5).timeout
	
	var position_tween = create_tween()
	var scale_tween = create_tween()
	
	position_tween.tween_property(self, "position", initial_position, animation_duration)
	scale_tween.tween_property(self, "scale", initial_scale, animation_duration)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
