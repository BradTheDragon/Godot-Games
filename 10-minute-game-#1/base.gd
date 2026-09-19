extends Sprite2D

var health = 100

@onready var health_bar := get_tree().root.get_node("GameScene/CanvasLayer/ProgressBar")
@onready var game_over_screen := get_tree().root.get_node("GameScene/CanvasLayer/GameOver")
@onready var spawner = get_tree().root.get_node("GameScene/Spawner")

func _on_area_2d_area_entered(area:Area2D) -> void:
	var node = area.get_parent()
	if node.is_in_group("enemys"):
		node.queue_free()
		health -= 20
		health_bar.value = health
		if health <= 0:
			spawner.game_running = false
			var tween = create_tween()
			tween.tween_property(Engine, "time_scale", 0.2, 1)
			await tween.finished
			game_over_screen.visible = true

func _on_button_pressed() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()