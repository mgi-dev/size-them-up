extends Node


var audio_players = [
	
]

const JUMP_SOUND = preload("res://assets/sound/jump.mp3")


func _ready():
	
	audio_players.append(AudioStreamPlayer.new())
	add_child(audio_players[0])  
	
	SignalBus.player_jump.connect(player_jump_sound)
	
	
func player_jump_sound():
	audio_players[0].stream = JUMP_SOUND
	audio_players[0].play()
	
