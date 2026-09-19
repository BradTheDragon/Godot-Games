extends Sprite2D

var speed := 275

func _physics_process(delta: float) -> void:
	var direction = Vector2.UP.rotated(rotation)
	position += direction * speed * delta
	if (position.x / direction.x) >= 800 or (position.y / direction.y) >= 800:
		self.queue_free()


func _on_area_2d_area_entered(area:Area2D) -> void:
	var node = area.get_parent()
	if node.is_in_group("enemys"):
		node.damage(25)
		self.queue_free()



