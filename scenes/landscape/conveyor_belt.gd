extends Area2D


var objects_on_belt = []


func _physics_process(delta):
	for object in objects_on_belt:
		object.linear_velocity.x = 50.0
		

func _on_body_entered(body):
	if body is RigidBody2D:
		objects_on_belt.append(body)


func _on_body_exited(body):
	if body is RigidBody2D:
		objects_on_belt.erase(body)
