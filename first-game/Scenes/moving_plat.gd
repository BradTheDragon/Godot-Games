extends AnimatableBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer



func _on_area_2d_body_exited(body: Node2D) -> void:
	animation_player.current_animation = "move"
