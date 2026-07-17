extends Node


var audio_players = [
	
]

var music_player: AudioStreamPlayer
const JUMP_SOUND = preload("res://assets/sound/jump.mp3")
const MUSIC_ONE = preload("res://assets/musics/D_D-Music-Industrial-Factory-Ambience.ogg")

func _ready():
	
	audio_players.append(AudioStreamPlayer.new())
	add_child(audio_players[0])  
	
	SignalBus.player_jump.connect(player_jump_sound)
	
	music_player = AudioStreamPlayer.new()
	add_child(music_player)  
	music_player.pitch_scale = 0.8
	music_player.stream = MUSIC_ONE
	music_player.stream.loop = true
	music_player.play()
	
	
func player_jump_sound():
	audio_players[0].stream = JUMP_SOUND
	audio_players[0].play()
	
