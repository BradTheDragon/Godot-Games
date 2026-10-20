extends Button



func _on_pressed() -> void:
	get_tree().reload_current_scene()


func _on_right_boarder_body_entered(body: Node2D) -> void:
	visible = true


func _on_left_boarder_body_entered(body: Node2D) -> void:
	visible = true
