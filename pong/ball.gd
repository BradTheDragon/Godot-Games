extends RigidBody2D

var SPEED := 1000
var max_bounce_angle := 60.0

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("paddles"):
		var paddle_shape: CollisionShape2D = body.get_node("CollisionShape2D")
		var paddle_height = paddle_shape.shape.get_rect().size.y
		var relative_y = (global_position.y - body.global_position.y) / (paddle_height / 2)
		relative_y = clamp(relative_y, -1, 1)
		var dir_x = 1 if global_position.x > body.global_position.x else -1
		var bounce_angle = relative_y * deg_to_rad(max_bounce_angle)
		var new_direction = Vector2(dir_x * cos(bounce_angle), sin(bounce_angle)).normalized()
		SPEED += 25
		print(SPEED)
		linear_velocity = new_direction * SPEED
		
