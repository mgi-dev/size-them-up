extends Node2D

@onready var camera: Camera2D = $Camera
@onready var player: Player = $Player
@onready var transition_sprite = $TransitionSprite2D

@export var entrance_door: Door
@export var exit_door: Door
@export var scroll_speed: float = 5000.0

func _ready():
	transition_sprite.modulate = Color(0.0, 0.0, 0.0, 1.0)
	display_transition_into_level()
	SignalBus.next_level.connect(display_transition_out_from_level)
	
	

func _process(delta):
	pass


func _physics_process(delta: float):
	update_camera_position()
	pass


func update_camera_position():
	camera.position.x = move_toward(camera.position.x, player.position.x + 100, scroll_speed)
	camera.position.y = move_toward(camera.position.y, player.position.y - 75, scroll_speed)

func display_transition_out_from_level(next_level):
	if next_level:
		transition_sprite.scale = Vector2(0.0, 0.0)
		transition_sprite.position = $Player.position - Vector2(0.5, 0.5)
		
		var tween = create_tween()
		var texture_size = transition_sprite.texture.get_size()
		var screen_diagonal = get_viewport().get_visible_rect().size.length()
		
		tween.tween_property(transition_sprite, "scale" , Vector2.ONE * (screen_diagonal / texture_size.x), 0.3)

		await tween.finished
		
		get_tree().change_scene_to_node(next_level.instantiate())


func display_transition_into_level():
	if entrance_door:
		entrance_door.reset_open()
	transition_sprite.position = $Player.position - Vector2(0.5, 0.5)
	var texture_size = transition_sprite.texture.get_size()
	var screen_diagonal = get_viewport().get_visible_rect().size.length()
	transition_sprite.scale = Vector2.ONE * (screen_diagonal / texture_size.x)
	await get_tree().create_timer(0.5).timeout
	var tween = create_tween()
	
	tween.tween_property(transition_sprite, "scale" , Vector2(0.0, 0.0), 0.3)

	await tween.finished
	
	if entrance_door:
		entrance_door.close_door()
	
	
		

	
