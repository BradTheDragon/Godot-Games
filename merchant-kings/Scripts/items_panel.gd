extends Control

@onready var item_nodes = self.get_node("Items").get_children()
@onready var game_manager = get_node("/root/GameManager")
@onready var return_button: Button = self.get_node("ReturnButton")
@onready var go_right_button: Button = $GoRight
@onready var go_left_button: Button = $GoLeft

var shown_item_range = 4
var items = []

func _ready() -> void:
	return_button.pressed.connect(return_button_pressed)
	go_left_button.pressed.connect(go_left)
	go_right_button.pressed.connect(go_right)

func update_go_buttons():
	if shown_item_range > 4:
		go_left_button.disabled = false
	else:
		go_left_button.disabled = true
	if items.size() > shown_item_range:
		go_right_button.disabled = false
	else:
		go_right_button.disabled = true

func open_panel():
	shown_item_range = 4
	items = game_manager.items.duplicate() + game_manager.upgrades.duplicate()
	update_go_buttons()
	display_items(shown_item_range)

func display_items(shown):
	var shown_items = []
	for i in range(shown - 4, shown):
		shown_items.append(i)
	for index in range(item_nodes.size()):
		if (items.size() - 1) >= shown_items[index]:
			item_nodes[index].stored = items[shown_items[index]]
			if shown_items[index] < game_manager.items.size():
				item_nodes[index].is_upgrade = false
			else:
				item_nodes[index].is_upgrade = true
			item_nodes[index].visible = true
			item_nodes[index].update()
		else:
			item_nodes[index].visible = false

func go_left():
	shown_item_range -= 4
	display_items(shown_item_range)
	update_go_buttons()

func go_right():
	shown_item_range += 4
	display_items(shown_item_range)
	update_go_buttons()

func return_button_pressed():
	game_manager.close_item_panel()