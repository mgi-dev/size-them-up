extends Node


var audio_players = [
	
]

var music_player: AudioStreamPlayer
#const JUMP_SOUND = preload("res://assets/sound/jump.mp3")
#const JUMP_SOUND = preload("res://assets/sound/jump.ogg")
const JUMP_SOUND = preload("res://assets/sound/Jump_2.ogg")

const MOUSE_CLICK = preload("res://assets/sound/matthewvakaliuk73627-mouse-click-290204.mp3")
const IMPORTANT_ITEM_COLLECTED = preload("res://assets/sound/level_up.mp3")
const BUZZER_INCORRECT = preload("res://assets/sound/freesound_community-wrong-47985-short.ogg")
const MUSIC_ONE = preload("res://assets/musics/burtysounds-synthwave-566759.mp3")


const game_event_to_sound = {
	Enums.GAME_EVENT.RESIZABLE_TOO_SMALL: BUZZER_INCORRECT,
	Enums.GAME_EVENT.RESIZABLE_BLOCKED: BUZZER_INCORRECT,
	
}

func _ready():
	for _index in range(10):
		var audio_player = AudioStreamPlayer.new()
		audio_player.bus = "HighSoundEffect"
		audio_players.append(audio_player)
		add_child(audio_player)
	
	SignalBus.player_jump.connect(player_jump_sound)
	SignalBus.important_item_collected.connect(func(): play_sound_effect(IMPORTANT_ITEM_COLLECTED))
	SignalBus.mouse_click.connect(func(): play_sound_effect(MOUSE_CLICK))
	SignalBus.game_event_happened.connect(func(event: Enums.GAME_EVENT): play_sound_effect(game_event_to_sound.get(event)))
	
	
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
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
	if sound:
		var audio_player = get_available_audio_player()
		audio_player.stream = sound
		audio_player.play()


func player_jump_sound():
	var audio_player = get_available_audio_player()
	audio_player.stream = JUMP_SOUND
	#audio_player.volume_db += 8.0
	audio_player.play()
	await audio_player.finished
	#audio_player.volume_db -= 8.0
	
	
func get_volume_db(bus_name: String) -> float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name))
	
	
func get_volume_linear(bus_name: String) -> float:
	return db_to_linear(get_volume_db(bus_name))
	
	
func set_volume(bus_name, volume: float):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index(bus_name),
		linear_to_db(volume)
)
	
