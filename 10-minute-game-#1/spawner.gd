extends Node2D

@onready var enemy = preload("res://enemy.tscn")
@onready var score_counter = get_tree().root.get_node("GameScene/CanvasLayer/Score")
var radius := 800
var base_enemy_speed := 125
var score := 0
var game_running = true


func _on_timer_timeout() -> void:
	var instance = enemy.instantiate()
	var random = randf_range(0, 2 * PI)
	instance.position = (Vector2.UP * radius).rotated(random)
	instance.rotation = random + PI
	instance.speed = base_enemy_speed + score
	get_tree().current_scene.add_child(instance)

func change_score(amount):
	if game_running:
		score += amount
		score_counter.text = str(score)
