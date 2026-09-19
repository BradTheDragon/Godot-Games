extends Control

var stored : Dictionary
var is_upgrade : bool
var sold : bool = false
@onready var name_label : Label = self.get_node("Control/VBoxContainer/Name")
@onready var description : Label = self.get_node("Control/VBoxContainer/Description")
@onready var image_rect : TextureRect = self.get_node("Control/VBoxContainer/TextureRect")
@onready var buy_button : Button = self.get_node("Control/MarginContainer/Button")
@onready var forsale_menu : Control = self.get_node("Control")
@onready var sold_label : Label = self.get_node("Label")

@onready var game_manager = get_node("/root/GameManager")

func _ready() -> void:
	buy_button.pressed.connect(buy)

func set_sold(is_sold: bool):
	if is_sold:
		forsale_menu.visible = false
		sold_label.visible = true
	else:
		forsale_menu.visible = true
		sold_label.visible = false
	sold = is_sold
	
func update():
	name_label.text = stored["name"]
	description.text = stored["description"]
	buy_button.text = "$" + str(stored["price"])
	
func buy():
	if game_manager.credits >= stored["price"]:
		if is_upgrade:
			game_manager.upgrades.append(stored.duplicate())
		else:
			game_manager.items.append(stored.duplicate())
		game_manager.credits -= stored["price"]
		set_sold(true)
