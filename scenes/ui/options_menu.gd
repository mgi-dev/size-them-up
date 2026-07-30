extends Control


func linear_value_to_slide_value(volume: float) -> float:
	return remap(volume, 0.0, 2.0, 0, 100)
	

func slide_value_to_linear_value(volume: float) -> float:
	return remap(volume, 0.0, 100.0, 0.0, 2.0)
	


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	$VBoxContainer2/VBoxContainer/MainVolumeContainer/HSlider.value = linear_value_to_slide_value(
		SoundController.get_volume_linear(Enums.SOUND_MASTER_BUS)
	)
	
	$VBoxContainer2/VBoxContainer/MusicVolumeContainer/HSlider.value = linear_value_to_slide_value(
		SoundController.get_volume_linear(Enums.SOUND_MUSIC_BUS)
	)
	
	$VBoxContainer2/VBoxContainer/SFXVolumeContainer/HSlider.value = linear_value_to_slide_value(
		SoundController.get_volume_linear(Enums.SOUND_SFX_BUS)
	)
	


func _on_main_volume_slider_value_changed(value):
	SoundController.set_volume(
		Enums.SOUND_MASTER_BUS, 
		slide_value_to_linear_value(value)
	)


func _on_music_volume_slider_value_changed(value):
		SoundController.set_volume(
		Enums.SOUND_MUSIC_BUS, 
		slide_value_to_linear_value(value)
	)


func _on_sfx_volume_slider_value_changed(value):
	SoundController.set_volume(
		Enums.SOUND_SFX_BUS, 
		slide_value_to_linear_value(value)
	)


func _on_test_sfx_button_button_down():
	SoundController.player_jump_sound()



func _on_back_button_button_up():
	SignalBus.mouse_click.emit()
	visible = false
