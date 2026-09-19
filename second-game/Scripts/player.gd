extends CharacterBody2D
@onready var left: RayCast2D = $left
@onready var right: RayCast2D = $right
@onready var up: RayCast2D = $up
@onready var down: RayCast2D = $down
var is_moving := false
var direction := Vector2.ZERO
var ticks_left := 0

func _physics_process(delta: float):
	if not is_moving:
		direction = Vector2.ZERO
		var can_move := false
	
		if Input.is_action_pressed("up"):
			direction.y -= 1
			can_move = up.is_colliding()
		elif Input.is_action_pressed("down"):
			direction.y += 1
			can_move = down.is_colliding()
		elif Input.is_action_pressed("left"):
			direction.x -= 1
			can_move = left.is_colliding()
		elif Input.is_action_pressed("right"):
			direction.x += 1
			can_move = right.is_colliding()
		direction = direction.normalized() * 1
		if not can_move:
			is_moving = true
			ticks_left = 8
	else:
		if ticks_left > 0:
			position += direction
			ticks_left -= 1
		else:
			is_moving = false
