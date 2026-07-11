extends CharacterBody2D

class_name Player

@onready var animated_sprite = $AnimatedSprite2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0



func _physics_process(delta):
	process_jump(delta)
	process_movements(delta)
	move_and_slide()


func process_movements(delta) -> void:
	var direction = Input.get_axis("player_move_right", "player_move_left")
	if direction:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = velocity.x < 0 
		animated_sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")
	
func process_jump(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
