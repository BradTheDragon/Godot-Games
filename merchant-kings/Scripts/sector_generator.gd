extends Node2D

@export var num_stars: int
@export var min_spacing: float
@export var num_connections: int
@onready var star_container: Node2D = $"../StarContainer"
@onready var path_container: Node2D = $"../PathContainer"
@onready var idle_ui_container: Control = $"../CanvasLayer/IdleUIContainer"
@onready var camera: Camera2D = $"../Camera2D"
@onready var star_scene := preload("res://Game Scenes/star_system.tscn")
@onready var path_scene := preload("res://Game Scenes/path_scene.tscn")
@onready var idle_star_ui := preload("res://Game Scenes/idle_star_ui.tscn")
var rng := RandomNumberGenerator.new()

func GenerateSector():
	var stars := []
	var positions := []
	
	var loop_cap := num_stars * 50 
	var num_tries := 0
	while not positions.size() >= num_stars:
		num_tries += 1
		var candidate = Vector2(rng.randf_range(276, -276), rng.randf_range(156, -125))
		var is_good = true
		for s in positions:
			if candidate.distance_to(s) < min_spacing:
				is_good = false
		if is_good == true:
			positions.append(candidate)
		if num_tries >= loop_cap:
			print("Reached loop_cap. Breaking.")
			break
	
	var index := 0
	for pos in positions:
		index += 1
		var star := star_scene.instantiate()
		star_container.add_child(star)
		star.position = pos
		star.name = "Star" + str(index)
		var idle_ui := idle_star_ui.instantiate()
		idle_ui_container.add_child(idle_ui)
		idle_ui.position = get_viewport().get_canvas_transform() * pos
		idle_ui.name = "IdleStarUI" + str(index)
		star.idle_ui = idle_ui
		star.idle_ui_panel = idle_ui.get_child(0)
		idle_ui.visible = false
		stars.append(star)
		print(star.name + " added at:" + str(pos))
		
	for star in stars:
		var distances := {}
		for i in stars:
			if i == star:
				continue
			distances[i] = star.position.distance_to(i.position)
		
		var sorted = distances.keys()
		sorted.sort_custom(func(a, b):
			return distances[a] < distances[b]
		)
		for l in range(num_connections):
			if not sorted[l] in star.neighbors:
				star.neighbors.append(sorted[l])
			if not star in sorted[l].neighbors:
				sorted[l].neighbors.append(star)
		
		for neighbor in star.neighbors:
			if star in neighbor.connections:
				continue
			var path = path_scene.instantiate()
			path_container.add_child(path)
			path.points = [star.position, neighbor.position]
			star.connections.append(neighbor)
