extends Node2D

signal arrived_at_star(star)

var velocity := Vector2.ZERO
var target_pos: Vector2
var moving := false
var min_speed := 4
var acceleration := 40
var deceleration := 100
var rot_speed := 2
var stopping_distance := 20
var starting_distance: int
var destination: Object

func start_movement(target: Vector2, star):
	target_pos = target
	destination = star
	starting_distance = global_position.distance_to(target_pos) - stopping_distance
	moving = true

func _physics_process(delta: float) -> void:
	if not moving:
		return
	
	var distance = global_position.distance_to(target_pos) - stopping_distance
	var direction = (target_pos - global_position).normalized()

	rotation = lerp_angle(rotation, direction.angle(), rot_speed * delta)
	
	var speed = (starting_distance * 1.5) * (distance / starting_distance)
	var desired_velocity := Vector2.ZERO
	if abs(Vector2.from_angle(rotation).angle_to(direction)) <= 0.5 or distance < 0:
		desired_velocity = Vector2.from_angle(rotation) * speed
	
	if abs(desired_velocity) >= abs(velocity):
		velocity = velocity.move_toward(desired_velocity, (acceleration * delta))
	else:
		velocity = velocity.move_toward(desired_velocity, (deceleration * delta))
	
	global_position += velocity * delta
	
	if abs(distance) < 1 and abs(velocity.length()) < 0.4:
		print("Finished moving!!")
		emit_signal("arrived_at_star", destination)
		moving = false

func _ready() -> void:
	print(self.get_path())
