extends Node2D



@onready var play_button = $PlayButton
@onready var exit_button = $ExitButton


func _ready():
	pass


func _process(delta):
	pass


func _on_play_button_button_up():
	SignalBus.mouse_click.emit()
	get_parent().get_parent().toggle_menu()
	# change_scene_to_node vs change_scene_to_packed
	


func _on_exit_button_button_up():
	SignalBus.mouse_click.emit()
	get_tree().quit()


func _on_options_button_button_up():
	SignalBus.mouse_click.emit()
	$OptionsMenu.visible = true
