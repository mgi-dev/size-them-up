extends Area2D

@export var display: bool


@export var recipient: String
@export var cc: String
@export var sender: String
@export var subject: String
@export var message: RichTextLabel

var mouse_over: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$recipient_label.text += " " + recipient
	$cc_label.text += " " + cc
	$sender_label.text += " " + sender
	$subject_label.text += " " + subject
	if message:
		$message_label.text += message.text
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if display:
		show()
	else:
		hide()


func _input(event):
	if event.is_action_released("click_on_button") and mouse_over or event.is_action_released("game_pad_click_on_button"):
		SignalBus.mouse_click.emit()
		display = false
	


func _on_mouse_entered():
	mouse_over = true



func _on_mouse_exited():
	mouse_over = false
