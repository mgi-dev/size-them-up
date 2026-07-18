extends Node

signal resize_mode_selected(resize_mode: Enums.RESIZE_MODE)
signal multi_resize_mode_changed(enabled: bool)



signal resized(size: float)
signal gauge_changed(percentage: float)

signal resize_ray_resize_up(collision_shape: CollisionShape2D, resize_mode: Enums.RESIZE_MODE)
signal resize_ray_resize_down(collision_shape: CollisionShape2D, resize_mode: Enums.RESIZE_MODE)


signal next_level(next_level: PackedScene)

signal game_event_happened(game_event: Enums.GAME_EVENT)


signal player_jump()
signal player_interact()
