extends Node


var audio_players = [
	
]

var music_player: AudioStreamPlayer
const JUMP_SOUND = preload("res://assets/sound/jump.mp3")
const IMPORTANT_ITEM_COLLECTED = preload("res://assets/sound/level_up.mp3")
const MUSIC_ONE = preload("res://assets/musics/D_D-Music-Industrial-Factory-Ambience.ogg")

func _ready():
	
	audio_players.append(AudioStreamPlayer.new())
	add_child(audio_players[0])  
	
	SignalBus.player_jump.connect(player_jump_sound)
	SignalBus.important_item_collected.connect(player_collect_important_sound)
	
	music_player = AudioStreamPlayer.new()
	add_child(music_player)  
	music_player.pitch_scale = 0.8
	music_player.stream = MUSIC_ONE
	music_player.stream.loop = true
	music_player.play()
	
	
func player_jump_sound():
	audio_players[0].stream = JUMP_SOUND
	audio_players[0].pitch_scale = 0.4
	audio_players[0].play()
	


	
func player_collect_important_sound():
	audio_players[0].stream = IMPORTANT_ITEM_COLLECTED
	
	audio_players[0].play()
	
