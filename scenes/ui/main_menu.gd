extends Control

class_name MainMenu


@onready var play_button = $MarginContainer/HBoxContainer/VBoxContainer/PlayButton
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/ExitButton
@export var start_level = preload("res://scenes/levels/tutorial/move_01.tscn")


func _ready():
	pass


func _process(delta):
	pass


func _on_play_button_button_up():
	SignalBus.mouse_click.emit()
	# change_scene_to_node vs change_scene_to_packed
	get_tree().change_scene_to_node(start_level.instantiate())


func _on_exit_button_button_up():
	get_tree().quit()
