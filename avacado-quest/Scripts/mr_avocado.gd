extends CharacterBody2D

#Variables
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@export var SPEED := 300.0
@export var JUMP_VELOCITY := -650.0
var jumping := false

#Movement and animation control
func _physics_process(delta: float) -> void:
	var state_machine = animation_tree["parameters/playback"]
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if jumping and is_on_floor():
		jumping = false

	if Input.is_action_just_pressed("jump") and is_on_floor() and not jumping:
		state_machine.travel("idle")
		await get_tree().process_frame
		state_machine.travel("jump")
		velocity.y = JUMP_VELOCITY
		jumping = true
		

	var direction := Input.get_axis("left", "right")
	
	if direction:
		velocity.x = direction * SPEED
		if velocity.x > 0:
			sprite_2d.flip_h = false
			if not jumping:
				state_machine.travel("walk")
		else:
			sprite_2d.flip_h = true  
			if not jumping:
				state_machine.travel("walk")
	elif is_on_floor() and not jumping:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		state_machine.travel("idle")
	
	if not is_on_floor() and velocity.y > 0:
		state_machine.travel("jump")
		
	move_and_slide()

func _on_killzone_die():
	call_deferred("_reload_scene")
	
func _reload_scene():
	get_tree().reload_current_scene()
