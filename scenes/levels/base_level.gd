extends Node2D

@onready var camera: Camera2D = $Camera
@onready var player: Player = $Player
@onready var background_music_player: AudioStreamPlayer = $AudioStreamPlayer

@export var scroll_speed: float = 5000.0

func _ready():
	print(background_music_player.stream.loop)
	background_music_player.pitch_scale = 0.8
	print(background_music_player.stream.loop)
	print(background_music_player.stream.get_class())

func _process(delta):
	pass


func _physics_process(delta: float):
	update_camera_position()
	pass


func update_camera_position():
	camera.position.x = move_toward(camera.position.x, player.position.x, scroll_speed)
	camera.position.y = move_toward(camera.position.y, player.position.y - 75, scroll_speed)
