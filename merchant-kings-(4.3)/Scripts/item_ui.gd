extends Control

var stored = {}
var is_upgrade: bool
@onready var name_label : Label = self.get_node("VBoxContainer/Name")
@onready var description : Label = self.get_node("VBoxContainer/Description")
@onready var image_rect : TextureRect = self.get_node("VBoxContainer/TextureRect")
@onready var use_button : Button = self.get_node("MarginContainer/Button")

@onready var game_manager = get_node("/root/GameManager")

func update():
	for connection in use_button.pressed.get_connections():
		use_button.pressed.disconnect(connection["callable"])
	name_label.text = stored["name"]
	description.text = stored["description"]
	use_button.pressed.connect(game_manager.use_item.bind(stored))
	if is_upgrade:
		use_button.visible = false
	else:
		use_button.visible = true