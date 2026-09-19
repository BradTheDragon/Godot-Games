extends StaticBody2D

@onready var timer: Timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var timer2: Timer = $Timer2

func _on_area_2d_body_entered(body) -> void:
	timer.start()

func _on_timer_timeout() -> void:
	sprite.visible = false
	collision.disabled = true
	timer2.start()

func _on_timer_2_timeout() -> void:
	sprite.visible = true
	collision.disabled = false
