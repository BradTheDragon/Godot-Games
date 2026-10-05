extends AnimatableBody2D


const SPEED = 300.0


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("up", "down")
	global_position.y += clamp(direction * SPEED * delta, -(global_position.y + 252), -(global_position.y - 252))
			
