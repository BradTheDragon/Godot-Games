extends AnimatableBody2D


const SPEED_MAX = 500
@onready var ball: RigidBody2D = $"../Ball"
@onready var timer: Timer = $Timer

var target_y = 0

func _physics_process(delta: float) -> void:
	var direction: int
	var speed: int
	if (ball.linear_velocity.x * position.x) > 0:
		if target_y < (global_position.y - 15):
			direction = -1
		elif target_y > (global_position.y + 15):
			direction = 1
		else:
			target_y = predict_y()
		#speed = abs(target_y - global_position.y) / ((global_position.x - ball.global_position.x) / ball.linear_velocity.x)
		speed = SPEED_MAX
	global_position.y += clamp(direction * speed * delta, -(global_position.y + 252), -(global_position.y - 252))
	
func predict_y():
	var impact_time = (global_position.x - ball.global_position.x) / ball.linear_velocity.x
	var delta_y = ball.linear_velocity.y * impact_time
	var rand_multiplier = (global_position.x - ball.global_position.x) / 966
	var y = ball.global_position.y + delta_y + (randi_range(-200, 200) * rand_multiplier)
	while y > 276 or y < -276:
		if y > 276:
			y = 276 - (y - 276)
		if y < -276:
			y = -276 - (y + 276)
	return clamp(y, -252, 252)
