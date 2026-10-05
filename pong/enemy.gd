extends AnimatableBody2D


const SPEED_MAX = 300
@onready var ball: RigidBody2D = $"../Ball"

func _physics_process(delta: float) -> void:
	var direction: int
	var target_y: int
	var speed: int
	if (ball.linear_velocity.x * position.x) > 0:
		target_y = predict_y()
		if target_y < (global_position.y - 15):
			direction = -1
		elif  target_y > (global_position.y + 15):
			direction = 1
		speed = abs(target_y - global_position.y) / ((global_position.x - ball.global_position.x) / ball.linear_velocity.x)
	global_position.y += clamp(direction * speed * delta, -(global_position.y + 252), -(global_position.y - 252))
	
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
