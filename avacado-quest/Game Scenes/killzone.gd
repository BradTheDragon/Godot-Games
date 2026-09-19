extends Area2D

signal die

func _on_body_entered(body: Node2D) -> void:
	emit_signal("die")
