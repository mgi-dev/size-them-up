extends Label


const MESSAGE_DISPLAY_DURATION = 0.5

var messages_text = {
	Enums.GAME_EVENT.EMPTY_GAUGE: "Gauge Vide",
	Enums.GAME_EVENT.FULL_GAUGE: "Gauge Pleine",
	Enums.GAME_EVENT.PLAYER_CLOSE_TO_RESIZABLE: "Too close !",
}
var messages_queue = []


func _ready():
	SignalBus.game_event_happened.connect(on_player_info_emitted)



func _process(delta):
	display_messages()
	pass


func display_messages() -> void:
	if text == "" and messages_queue:
		text = messages_queue[-1]
		modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.1)
		tween.tween_interval(0.8)
		tween.parallel().tween_property(self, "modulate:a", 0.0, MESSAGE_DISPLAY_DURATION)
		tween.parallel().tween_property(self, "position:y", position.y - 20, MESSAGE_DISPLAY_DURATION)

		await tween.finished
		
		position.y += 20
		text = ""
		messages_queue.pop_back()

func on_player_info_emitted(game_event: Enums.GAME_EVENT) -> void:
	if messages_text[game_event] not in messages_queue:
		messages_queue.append(messages_text[game_event])
	
