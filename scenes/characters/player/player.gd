extends CharacterBody2D

class_name Player

@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox = $CollisionShape2D
@onready var audio_fx_player = $AudioFXPlayer


const SPEED = 300.0
const ACCELERATION = 2000.0
const JUMP_VELOCITY = -350.0
const CLIMB_SPEED = 200.0

# Todo: make a player state object.
var is_near_ladder: bool = false
var is_climbing: bool = false
var current_ladders: Array[Area2D]

var player_state_machine: PlayerStateMachine


func _ready() -> void:
	player_state_machine =  preload("res://scenes/characters/player/states/PlayerStateMachine.gd").new(self)


func _physics_process(delta):
	player_state_machine.set_state(get_next_state())
	player_state_machine.update(delta)
	move_and_slide()


func get_next_state()-> PlayerState:
	if Input.is_action_just_pressed("player_jump"):
		if is_on_floor() or is_climbing:
			# Allow jump from ladder.
			return player_state_machine.jump_state
	
	if is_climbing:
		# stick to the ladder while not outed correctly.
		return player_state_machine.climb_state
	
	if is_near_ladder:
		if Input.is_action_pressed("player_climb") or Input.is_action_pressed("player_down"):
			return player_state_machine.climb_state
	
	if Input.get_axis("player_move_left", "player_move_right"):
		return player_state_machine.walk_state
	
	return player_state_machine.idle_state
	
var toto = []
	
func _on_detector_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.is_in_group(Enums.CLIMBABLE_GROUP):
		current_ladders.append(area)
		is_near_ladder = true
		is_climbing = false

func _on_detector_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if area:
		# If the entered area is queue_free, this will receive None
		if area.is_in_group(Enums.CLIMBABLE_GROUP):
			current_ladders.erase(area)
		
		if not current_ladders:
			is_near_ladder = false
			is_climbing = false

func _input(event):
	if event.is_action_pressed("interact"):
		SignalBus.player_interact.emit()


func debug():
	print(player_state_machine.current_state)
