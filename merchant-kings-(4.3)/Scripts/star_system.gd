extends Area2D

signal star_pressed(star)

@onready var rand = RandomNumberGenerator.new()
@onready var image = $Sprite2D

var neighbors := []
var connections := []
var visited = false

#######UI Variables########
var idle_ui: Object
var idle_ui_panel: Control
var market_trend_label: Label
var market_cost_label: Label

#######Market Variables######
var base_price: int
var base_trend: int
var sell_percentage: float
var current_price: int
var trend: int
var trend_strength: float
var volatility: int
var minimum: int
var maximum: int

########Market System#######
func init_market(_base_price, _sell_perc, _trend, _trend_strength, _volatility, _min, _max, starting_diviation):
	base_price = _base_price
	sell_percentage = _sell_perc
	current_price = _base_price
	trend_strength = _trend_strength
	base_trend = _trend
	volatility = _volatility
	minimum = _min
	maximum = _max
	trend = roundi(rand.randfn(base_trend, starting_diviation))
	current_price += int(rand.randfn(0, 10))
	current_price = clampi(current_price, minimum, maximum)
	print(str(current_price) + ", " + str(trend))

	if idle_ui:
		market_trend_label = idle_ui.get_node("VBoxContainer/Market Trend")
		market_cost_label = idle_ui.get_node("VBoxContainer/Cost")
	refresh_idle_labels()


func update_market():
	if rand.randf() > trend_strength:
		trend += -abs(int(rand.randfn(0, volatility)))
	else:
		trend += abs(int(rand.randfn(0, volatility)))
	current_price += trend
	current_price = clampi(current_price, minimum, maximum)
	print(str(current_price) + ", " + str(trend))
	refresh_idle_labels()


func refresh_idle_labels():
	if market_trend_label == null or market_cost_label == null:
		return
	if trend > 0:
		market_trend_label.text = "⭧ +" + str(trend)
	elif trend < 0:
		market_trend_label.text = "⭨ " + str(trend)
	else:
		market_trend_label.text = "⭢ " + str(trend)
	market_cost_label.text = str(current_price)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("star_pressed", self)
