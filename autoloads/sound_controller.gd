extends Node


var audio_players = [
	
]

var music_player: AudioStreamPlayer
const JUMP_SOUND = preload("res://assets/sound/jump.mp3")
const MOUSE_CLICK = preload("res://assets/sound/matthewvakaliuk73627-mouse-click-290204.mp3")
const IMPORTANT_ITEM_COLLECTED = preload("res://assets/sound/level_up.mp3")
const MUSIC_ONE = preload("res://assets/musics/D_D-Music-Industrial-Factory-Ambience.ogg")

func _ready():
	for _index in range(10):
		var audio_player = AudioStreamPlayer.new()
		audio_players.append(audio_player)
		add_child(audio_player)
	
	SignalBus.player_jump.connect(player_jump_sound)
	SignalBus.important_item_collected.connect(func(): play_sound_effect(IMPORTANT_ITEM_COLLECTED))
	SignalBus.mouse_click.connect(func(): play_sound_effect(MOUSE_CLICK))
	
	
	music_player = AudioStreamPlayer.new()
	add_child(music_player)  
	music_player.pitch_scale = 0.8
	music_player.stream = MUSIC_ONE
	music_player.stream.loop = true
	music_player.play()
	


func get_available_audio_player() -> AudioStreamPlayer:
	for audio_player in audio_players:
		if !audio_player.is_playing(): 
			return audio_player
	# No player available ? just return the first one and call it a day.
	return audio_players[0]

	
func play_sound_effect(sound):
	var audio_player = get_available_audio_player()
	audio_player.stream = sound
	audio_player.play()

func player_jump_sound():
	var audio_player = get_available_audio_player()
	audio_player.stream = JUMP_SOUND
	audio_player.pitch_scale = 0.4
	audio_player.play()
