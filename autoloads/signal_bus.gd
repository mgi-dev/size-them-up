extends Node

signal resized(size: float)
signal gauge_changed(percentage: float)

signal resize_ray_resize_up(collision_shape: CollisionShape2D)
signal resize_ray_resize_down(collision_shape: CollisionShape2D)

signal next_level(next_level: PackedScene)

signal game_event_happened(game_event: Enums.GAME_EVENT)


signal player_jump()
signal player_interact()
