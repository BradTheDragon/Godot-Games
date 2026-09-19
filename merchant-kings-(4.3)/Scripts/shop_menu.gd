extends Control

@onready var upgrade_nodes = self.get_node("Upgrades").get_children()
@onready var item_nodes = self.get_node("Items").get_children()
@onready var credits_label = self.get_node("Credits")
@onready var new_sector_button = self.get_node("StartButton")

@onready var game_manager = get_node("/root/GameManager")
@onready var go_right_button: Button = $GoRight
@onready var go_left_button: Button = $GoLeft


var upgrade_list = []
var item_list =  []
var sold_upgrades = []
var shown_upgrade_range = 4

func _process(delta: float) -> void:
	credits_label.text = "$" + str(game_manager.credits)

func _ready() -> void:
	new_sector_button.pressed.connect(start_button_pressed)
	go_left_button.pressed.connect(go_left)
	go_right_button.pressed.connect(go_right)
	
	var upgrade_file = FileAccess.open("res://upgrades.json", FileAccess.READ)
	var upgrade_string = upgrade_file.get_as_text()
	upgrade_file.close()
	var json = JSON.new()
	json.parse(upgrade_string)
	upgrade_list = json.data
	
	var item_file = FileAccess.open("res://items.json", FileAccess.READ)
	var item_string = item_file.get_as_text()
	item_file.close()
	json = JSON.new()
	json.parse(item_string)
	item_list = json.data

func update_shop():
	shown_upgrade_range = 4
	reset_all()
	update_go_buttons()
	display_upgrades(shown_upgrade_range)
	var available_items = item_list.duplicate()
	for node in item_nodes:
		node.set_sold(false)
		if available_items.size() > 0:
			node.stored = available_items.pick_random().duplicate()
			available_items.erase(node.stored)
			node.is_upgrade = false
			node.update()
		else:
			node.visible = false

func display_upgrades(shown):
	var shown_upgrades = []
	for i in range(shown - 4, shown):
		shown_upgrades.append(i)
	for index in range(upgrade_nodes.size()):
		if upgrade_nodes[index].sold:
			sold_upgrades.append(upgrade_list.find(upgrade_nodes[index].stored))
		if (upgrade_list.size() - 1) >= shown_upgrades[index]:
			upgrade_nodes[index].stored = upgrade_list[shown_upgrades[index]]
			upgrade_nodes[index].visible = true
			upgrade_nodes[index].is_upgrade = true
			upgrade_nodes[index].update()
			if shown_upgrades[index] in sold_upgrades:
				upgrade_nodes[index].set_sold(true)
			else:
				upgrade_nodes[index].set_sold(false)
		else:
			upgrade_nodes[index].visible = false
			
func update_go_buttons():
	if shown_upgrade_range > 4:
		go_left_button.disabled = false
	else:
		go_left_button.disabled = true
	if upgrade_list.size() > shown_upgrade_range:
		go_right_button.disabled = false
	else:
		go_right_button.disabled = true

func start_button_pressed():
	for item in game_manager.items:
		if item["unique"] and item in item_list:
			item_list.erase(item)
	game_manager.start_new_sector()

func go_left():
	shown_upgrade_range -= 4
	display_upgrades(shown_upgrade_range)
	update_go_buttons()
	
func go_right():
	shown_upgrade_range += 4
	display_upgrades(shown_upgrade_range)
	update_go_buttons()
	
func reset_all():
	for node in upgrade_nodes:
		node.set_sold(false)
	sold_upgrades = []

