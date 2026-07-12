extends Label



var messages_text = {
	Enums.GAME_EVENT.EMPTY_GAUGE: "Gauge Vide",
	Enums.GAME_EVENT.FULL_GAUGE: "Gauge Pleine",
	Enums.GAME_EVENT.PLAYER_CLOSE_TO_RESIZABLE: "Too close !",
}
var messages_queue = []

# a displayed message go here and cannot be displayed again for a time.
# TODO: code the thing
var displayed_messages = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.game_event_happened.connect(on_player_info_emitted)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	display_messages()
	print(messages_queue)
	pass


func display_messages() -> void:
	if text == "" and messages_queue:
		text = messages_queue[-1]
		await get_tree().create_timer(0.5).timeout
		text = " "
		await get_tree().create_timer(0.5).timeout
		text = ""
		messages_queue.pop_back()

func on_player_info_emitted(game_event: Enums.GAME_EVENT) -> void:
	if messages_text[game_event] not in messages_queue:
		messages_queue.append(messages_text[game_event])
	
