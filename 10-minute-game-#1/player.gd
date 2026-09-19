extends Sprite2D

var speed := 4
var radius := 30
var pos := Vector2.UP * radius

@onready var bullet := preload("res://bullet.tscn")

func _process(delta: float) -> void:
	var movement = Input.get_axis("left", "right")
	pos = pos.rotated(speed * delta * movement)
	position = pos
	rotation += speed * delta * movement
	

func _on_timer_timeout() -> void:
	var instance = bullet.instantiate()
	instance.rotation = rotation
	instance.position = position
	get_tree().current_scene.add_child(instance)