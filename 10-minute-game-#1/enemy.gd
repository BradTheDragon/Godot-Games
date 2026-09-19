extends Sprite2D

var speed: int
var health := 100
@onready var spawner = get_tree().root.get_node("GameScene/Spawner")

func _process(delta: float) -> void:
	var direction = Vector2.UP.rotated(rotation)
	position += direction * speed * delta

func damage(amount: int):
	health -= amount
	self_modulate.a = float(health) / 100
	if health <= 0:
		spawner.change_score(1)
		self.queue_free()
