extends Sprite2D

@onready var ball: RigidBody2D = $"../Ball"

func _process(delta: float) -> void:
	var target_y: float
	if (ball.linear_velocity.x * position.x) > 0:
		#visible = true
		target_y = predict_y()
		position.y = target_y
	else:
		visible = false

func predict_y():
	var impact_time = (global_position.x - ball.global_position.x) / ball.linear_velocity.x
	var delta_y = ball.linear_velocity.y * impact_time
	var y = ball.global_position.y + delta_y
	while y > 276 or y < -276:
		if y > 276:
			y = 276 - (y - 276)
		if y < -276:
			y = -276 - (y + 276)
	return y
