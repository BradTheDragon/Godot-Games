extends Area2D

@onready var mouseIn := false

func _on_mouse_entered() -> void:
	print("Mouse Entered")
	mouseIn = true

func _on_mouse_exited() -> void:
	print("Mouse Exited")
	mouseIn = false

func _input(event):
	if event is InputEventMouseButton and mouseIn == true:
		if event.pressed == true:
			print("IT WORKED!!!")
	
