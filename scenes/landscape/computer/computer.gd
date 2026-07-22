extends Node2D


@export var enable: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	if not enable:
		$Flashing.is_flashing = false
		$Interractable.already_interacted = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_interact():
	if enable:
		SignalBus.mouse_click.emit()
		$Flashing.is_flashing = false
		var parent = get_parent()
		if parent:
			if parent.has_method("on_interact"):
				parent.on_interact(self)
