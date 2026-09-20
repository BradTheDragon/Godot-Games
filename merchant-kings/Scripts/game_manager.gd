extends Node

enum PlayState { DOCKED, DECIDING, MOVING, SHOPPING }

@export var move_timer_seconds := 10.0

@onready var SECTOR_GENERATOR = get_tree().root.get_node("/root/GalaxyMap/SectorGenerator")
@onready var SHIP = get_tree().root.get_node("/root/GalaxyMap/PlayerShip")
@onready var CAMERA = get_tree().root.get_node("/root/GalaxyMap/Camera2D")

#########Global Variables########
var starting_stats: Dictionary
var stats: Dictionary
var sector: int
var sector_mortgages: Array
var current_mortgage: int
var fuel: int
var credits: int
var cargo: int
var play_state: PlayState
var upgrades: Array
var depleted_upgrades: Array
var items: Array

#########Current Sector Variables########
var stars = []
@onready var path_container = get_tree().root.get_node("/root/GalaxyMap/PathContainer")
@onready var star_container = get_tree().root.get_node("/root/GalaxyMap/StarContainer")
@onready var idle_ui_container = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/IdleUIContainer")

#########Ship Variables########
var current_star: Object

var move_timer: Timer

#########HUD UI Variables#########
@onready var hud_ui = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/Hud")
@onready var credits_label = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/Hud/HBoxContainer/Credits")
@onready var fuel_label = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/Hud/HBoxContainer/Fuel")
@onready var cargo_label = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/Hud/HBoxContainer/Cargo")
@onready var mortgage_label = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/Hud/Mortgage")
@onready var finish_sector_button = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/Hud/FinishSectorButton")
@onready var move_timer_label = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/Hud/MoveTimerLabel")

#########Finish Sector UI Variables#########
@onready var finish_sector_ui = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/FinishSectorUI")
@onready var final_score_label = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/FinishSectorUI/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/Control/Label")
@onready var final_mortgage_label = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/FinishSectorUI/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/Control2/Label3")
@onready var final_credits_label = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/FinishSectorUI/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/Control3/Label3")
@onready var open_store_button = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/FinishSectorUI/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/MarginContainer/Button")
@onready var game_over_label = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/FinishSectorUI/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/MarginContainer/Label")

#########Shop / Market UI / Item Panel###########
@onready var shop_ui = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/ShopUI")
@onready var market_screen = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/MarketScreen")
@onready var open_item_panel_button = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/Hud/OpenItemPanelButton")
@onready var item_panel = get_tree().root.get_node("/root/GalaxyMap/CanvasLayer/Items Panel")

@onready var menu_screen = $/root/GalaxyMap/CanvasLayer/MenuScreen
@onready var start_game_button: Button = $/root/GalaxyMap/CanvasLayer/MenuScreen/VBoxContainer/MarginContainer/VBoxContainer/StartGameButton
@onready var quit_game_button: Button = $/root/GalaxyMap/CanvasLayer/MenuScreen/VBoxContainer/MarginContainer/VBoxContainer/QuitGameButton

#########MAIN FUNCTIONS#########
func start_game():
	starting_stats = {"starting_fuel": 6,
			"starting_credits": 0,
			"starting_cargo": 0,
			"cargo_max": 15,
			"market_min": 0,
			"market_max": 0,
			"market_volatility": 0,
			"ignore_paths": false,
			"ignore_visited": false
			}
	stats = {}
	sector = 0
	sector_mortgages = [0, 700, 1200, 1700, 2200]
	current_mortgage = 0
	credits = 350
	cargo = 0
	play_state = PlayState.DOCKED
	upgrades = []
	depleted_upgrades = []
	items = [{
		"name": "Emergancy Fuel",
		"description": "Use this to gain one more fuel (one time use)",
		"usable": true,
		"unique": false
	}]
	
	menu_screen.visible = false
	hud_ui.visible = true
	idle_ui_container.visible = true
	start_sector()

func quit_game():
	get_tree().quit()

func start_sector():
	await get_tree().process_frame
	sector += 1
	if sector < sector_mortgages.size():
		current_mortgage = sector_mortgages[sector]
	else:
		current_mortgage = sector_mortgages[sector_mortgages.size() - 1]
	stats = starting_stats.duplicate()
	for depleted in depleted_upgrades:
		upgrades.erase(depleted)
	depleted_upgrades = []
	for upgrade in upgrades:
		if upgrade["isdone"] != true:
			if upgrade["isdone"] == false:
				upgrade["isdone"] = true
				depleted_upgrades.append(upgrade.duplicate())
			var keys = upgrade["effects"].keys()
			for key in keys:
				stats[key] += upgrade["effects"][key]
	fuel = stats["starting_fuel"]
	cargo = clamp(0 + stats["starting_cargo"], 0, stats["cargo_max"])
	credits += stats["starting_credits"]
	fuel_label.text = "Fuel: " + str(fuel)
	credits_label.text = "$: " + str(credits)
	cargo_label.text = "Cargo: " + str(cargo) + "/" + str(stats["cargo_max"])
	mortgage_label.text = "Mortgage: " + str(current_mortgage)
	SECTOR_GENERATOR.GenerateSector()
	var star1 = star_container.get_children()[0]
	SHIP.position = Vector2(star1.position.x - 20, star1.position.y)
	SHIP.rotation = 0
	current_star = star1
	stars = star_container.get_children()
	for star in stars:
		star.star_pressed.connect(star_pressed)
		star.init_market(50, 0.90, 0, 0.50, 2 + stats["market_volatility"], 20 + stats["market_min"], 100 + stats["market_max"], 3)
	arrived_at_star(star1)

func star_pressed(star):
	if play_state != PlayState.DECIDING:
		return
	if (SHIP.moving == false and star != current_star and fuel > 0) and (star in current_star.neighbors or stats['ignore_paths']) and (star.visited == false or stats["ignore_visited"]):
		_stop_move_timer()
		play_state = PlayState.MOVING
		_set_idle_ui_visibility(false)
		finish_sector_button.disabled = true
		open_item_panel_button.disabled = true
		fuel -= 1
		fuel_label.text = "Fuel: " + str(fuel)
		var visited_star_texture = load("res://visited_star_image.png")
		if !current_star.visited:
			current_star.image.texture = visited_star_texture
			current_star.visited = true
		SHIP.start_movement(star.position, star)

func advance_market_tick():
	for star in stars:
		star.update_market()

func arrived_at_star(star):
	current_star = star
	play_state = PlayState.DOCKED
	_stop_move_timer()
	_set_idle_ui_visibility(false)
	advance_market_tick()
	market_screen.open(star)
	_update_finish_sector_button()
	_update_move_timer_label()

func _on_left_market():
	play_state = PlayState.DECIDING
	open_item_panel_button.disabled = false
	_set_idle_ui_visibility(true)
	_update_finish_sector_button()
	_start_move_timer()

func buy_or_sell(cost = null, amount = null):
	if (credits + cost) < 0 or (cargo + amount) < 0:
		pass
	else:
		credits += cost
		cargo = clamp(cargo + amount, 0, stats["cargo_max"])
		credits_label.text = "$: " + str(credits)
		cargo_label.text = "Cargo: " + str(cargo) + "/" + str(stats["cargo_max"])

func finish_sector():
	_stop_move_timer()
	market_screen.visible = false
	hud_ui.visible = false
	finish_sector_ui.visible = true
	final_score_label.text = "+" + str(credits)
	final_mortgage_label.text = "-" + str(current_mortgage)
	credits = credits - current_mortgage
	final_credits_label.text = str(credits)
	if credits < 0:
		open_store_button.visible = false
		game_over_label.visible = true

func open_store():
	_stop_move_timer()
	market_screen.visible = false
	finish_sector_ui.visible = false
	shop_ui.visible = true
	shop_ui.update_shop()
	play_state = PlayState.SHOPPING

func reset_map():
	_stop_move_timer()
	market_screen.visible = false
	for child in star_container.get_children():
		stars.erase(child)
		child.queue_free()
	for path in path_container.get_children():
		path.queue_free()
	for ui in idle_ui_container.get_children():
		ui.queue_free()
	await get_tree().process_frame
	
func start_new_sector():
	reset_map()
	stars = []
	await get_tree().process_frame
	shop_ui.visible = false
	hud_ui.visible = true
	play_state = PlayState.DOCKED
	start_sector()

func _set_idle_ui_visibility(show_idle: bool) -> void:
	for star in stars:
		if star.idle_ui == null:
			continue
		if show_idle and play_state == PlayState.DECIDING:
			star.idle_ui.visible = not star.visited
		else:
			star.idle_ui.visible = show_idle

func _refresh_all_idle_labels() -> void:
	for star in stars:
		star.refresh_idle_labels()

func _start_move_timer() -> void:
	if fuel <= 0:
		_update_move_timer_label()
		return
	move_timer.wait_time = move_timer_seconds
	move_timer.paused = false
	move_timer.start()
	_update_move_timer_label()

func _stop_move_timer() -> void:
	move_timer.stop()
	_update_move_timer_label()

func _on_move_timer_timeout() -> void:
	if play_state != PlayState.DECIDING:
		return
	if fuel <= 0:
		_stop_move_timer()
		_update_move_timer_label()
		return
	fuel -= 1
	fuel_label.text = "Fuel: " + str(fuel)
	advance_market_tick()
	_refresh_all_idle_labels()
	if fuel <= 0:
		_stop_move_timer()
		_update_move_timer_label()
		return
	move_timer.wait_time = move_timer_seconds
	move_timer.start()
	_update_move_timer_label()

func _update_finish_sector_button() -> void:
	finish_sector_button.disabled = play_state == PlayState.MOVING

func _update_move_timer_label() -> void:
	if play_state == PlayState.DECIDING and move_timer.time_left > 0:
		var seconds := int(ceil(move_timer.time_left))
		move_timer_label.visible = true
		move_timer_label.text = "Next move: " + str(seconds) + "s (or -1 Fuel)"
	elif play_state == PlayState.DECIDING and fuel <= 0:
		move_timer_label.visible = true
		move_timer_label.text = "Out of fuel — Finish Sector"
	else:
		move_timer_label.visible = false

func _process(_delta: float) -> void:
	_update_move_timer_label()

func open_item_panel():
	market_screen.visible = false
	hud_ui.visible = false
	_set_idle_ui_visibility(false)
	move_timer.paused = true
	item_panel.visible = true
	item_panel.open_panel()

func close_item_panel():
	item_panel.visible = false
	if move_timer.is_stopped():
		_start_move_timer()
	else:
		move_timer.paused = false
	hud_ui.visible = true
	_set_idle_ui_visibility(true)

func use_item(item):
	call(item["name"].replace(" ", "_"))
	items.erase(item)
	item_panel.open_panel()

#########GAME LOOP########
func _ready() -> void:
	move_timer = Timer.new()
	move_timer.one_shot = true
	add_child(move_timer)
	move_timer.timeout.connect(_on_move_timer_timeout)

	await get_tree().process_frame
	SHIP.arrived_at_star.connect(arrived_at_star)
	finish_sector_button.pressed.connect(finish_sector)
	open_item_panel_button.pressed.connect(open_item_panel)
	open_store_button.pressed.connect(open_store)
	market_screen.left_market.connect(_on_left_market)
	
	start_game_button.pressed.connect(start_game)
	quit_game_button.pressed.connect(quit_game)
	
	move_timer_label.visible = false

##########Item Functions##########
func Emergancy_Fuel():
	fuel += 1
	fuel_label.text = "Fuel: " + str(fuel)

func Bag_of_Holding():
	stats["cargo_max"] += 50
	cargo_label.text = "Cargo: " + str(cargo) + "/" + str(stats["cargo_max"])

func AI_Navigation_Unit():
	while play_state == PlayState.DECIDING:
		path_container.visible = false
		stats["ignore_paths"] = true
		await get_tree().process_frame
	stats["ignore_paths"] = false
	path_container.visible = true

func Backup_Camera():
	var visited_stars = []
	var visited_star_texture = load("res://visited_star_image.png")
	var star_texture = load("res://star_image.png")
	for star in stars:
		if star.visited:
			visited_stars.append(star)
	while play_state == PlayState.DECIDING:
		stats["ignore_visited"] = true
		for star in visited_stars:
			star.image.texture = star_texture
			star.visited = false
		await get_tree().process_frame
	stats["ignore_visited"] = false
	for star in visited_stars:
		star.image.texture = visited_star_texture
		star.visited = true

func Reactor_Cooler():
	move_timer.wait_time = move_timer.time_left + 10
	move_timer.start()
	move_timer.paused = true
