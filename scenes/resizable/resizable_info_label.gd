extends Label


const MESSAGE_DISPLAY_DURATION = 0.9


var messages_text = {
	Enums.GAME_EVENT.RESIZABLE_TOO_SMALL: "Too small",
	Enums.GAME_EVENT.RESIZABLE_BLOCKED: "Blocked",
	
}
var messages_queue = []


func _ready():
	pass
	# SignalBus.game_event_happened.connect(on_game_event_received)



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
		await get_tree().create_timer(1.2).timeout
		
		
func on_game_event_received(game_event: Enums.GAME_EVENT) -> void:
	var message = messages_text.get(game_event)
	if message:
		if messages_text[game_event] not in messages_queue:
			messages_queue.append(messages_text[game_event])
	
