extends Control

signal left_market

var docked_star: Node = null
var buy_quantity := 0
var sell_quantity := 0

@onready var game_manager = get_node("/root/GameManager")

@onready var star_name_label: Label = $MarginContainer/VBoxContainer/HeaderHBox/StarNameLabel
@onready var buy_price_label: Label = $MarginContainer/VBoxContainer/HeaderHBox/BuyPriceLabel
@onready var sell_price_label: Label = $MarginContainer/VBoxContainer/HeaderHBox/SellPriceLabel
@onready var trend_label: Label = $MarginContainer/VBoxContainer/HeaderHBox/TrendLabel
@onready var credits_label: Label = $MarginContainer/VBoxContainer/PlayerStatsHBox/CreditsLabel
@onready var cargo_label: Label = $MarginContainer/VBoxContainer/PlayerStatsHBox/CargoLabel
@onready var fuel_label: Label = $MarginContainer/VBoxContainer/PlayerStatsHBox/FuelLabel

@onready var buy_qty_label: Label = $MarginContainer/VBoxContainer/TradeHBox/BuySection/MarginContainer/VBoxContainer/QtyRow/BuyQtyLabel
@onready var buy_total_label: Label = $MarginContainer/VBoxContainer/TradeHBox/BuySection/MarginContainer/VBoxContainer/BuyTotalLabel
@onready var sell_qty_label: Label = $MarginContainer/VBoxContainer/TradeHBox/SellSection/MarginContainer/VBoxContainer/QtyRow/SellQtyLabel
@onready var sell_total_label: Label = $MarginContainer/VBoxContainer/TradeHBox/SellSection/MarginContainer/VBoxContainer/SellTotalLabel

@onready var buy_minus_btn: Button = $MarginContainer/VBoxContainer/TradeHBox/BuySection/MarginContainer/VBoxContainer/QtyRow/BuyMinus
@onready var buy_plus_btn: Button = $MarginContainer/VBoxContainer/TradeHBox/BuySection/MarginContainer/VBoxContainer/QtyRow/BuyPlus
@onready var buy_5_btn: Button = $MarginContainer/VBoxContainer/TradeHBox/BuySection/MarginContainer/VBoxContainer/PresetRow/Buy5
@onready var buy_10_btn: Button = $MarginContainer/VBoxContainer/TradeHBox/BuySection/MarginContainer/VBoxContainer/PresetRow/Buy10
@onready var buy_max_btn: Button = $MarginContainer/VBoxContainer/TradeHBox/BuySection/MarginContainer/VBoxContainer/PresetRow/BuyMax
@onready var buy_reset_btn: Button = $MarginContainer/VBoxContainer/TradeHBox/BuySection/MarginContainer/VBoxContainer/PresetRow/BuyReset
@onready var buy_btn: Button = $MarginContainer/VBoxContainer/TradeHBox/BuySection/MarginContainer/VBoxContainer/BuyButton

@onready var sell_minus_btn: Button = $MarginContainer/VBoxContainer/TradeHBox/SellSection/MarginContainer/VBoxContainer/QtyRow/SellMinus
@onready var sell_plus_btn: Button = $MarginContainer/VBoxContainer/TradeHBox/SellSection/MarginContainer/VBoxContainer/QtyRow/SellPlus
@onready var sell_5_btn: Button = $MarginContainer/VBoxContainer/TradeHBox/SellSection/MarginContainer/VBoxContainer/PresetRow/Sell5
@onready var sell_10_btn: Button = $MarginContainer/VBoxContainer/TradeHBox/SellSection/MarginContainer/VBoxContainer/PresetRow/Sell10
@onready var sell_max_btn: Button = $MarginContainer/VBoxContainer/TradeHBox/SellSection/MarginContainer/VBoxContainer/PresetRow/SellMax
@onready var sell_reset_btn: Button = $MarginContainer/VBoxContainer/TradeHBox/SellSection/MarginContainer/VBoxContainer/PresetRow/SellReset
@onready var sell_btn: Button = $MarginContainer/VBoxContainer/TradeHBox/SellSection/MarginContainer/VBoxContainer/SellButton

@onready var leave_btn: Button = $MarginContainer/VBoxContainer/FooterHBox/LeaveButton


func _ready() -> void:
	buy_minus_btn.pressed.connect(_on_buy_minus)
	buy_plus_btn.pressed.connect(_on_buy_plus)
	buy_5_btn.pressed.connect(func(): _add_buy_quantity(5))
	buy_10_btn.pressed.connect(func(): _add_buy_quantity(10))
	buy_max_btn.pressed.connect(func(): _set_buy_quantity(get_max_buy_qty()))
	buy_reset_btn.pressed.connect(func(): _set_buy_quantity(0))
	buy_btn.pressed.connect(_on_buy_pressed)

	sell_minus_btn.pressed.connect(_on_sell_minus)
	sell_plus_btn.pressed.connect(_on_sell_plus)
	sell_5_btn.pressed.connect(func(): _add_sell_quantity(5))
	sell_10_btn.pressed.connect(func(): _add_sell_quantity(10))
	sell_max_btn.pressed.connect(func(): _set_sell_quantity(get_max_sell_qty()))
	sell_reset_btn.pressed.connect(func(): _set_sell_quantity(0))
	sell_btn.pressed.connect(_on_sell_pressed)

	leave_btn.pressed.connect(_on_leave_pressed)


func open(star: Node) -> void:
	docked_star = star
	buy_quantity = 0
	sell_quantity = 0
	visible = true
	refresh()


func refresh() -> void:
	if docked_star == null:
		return

	star_name_label.text = docked_star.name
	buy_price_label.text = "Buy: $" + str(docked_star.current_price)
	sell_price_label.text = "Sell: $" + str(get_sell_unit_price())
	trend_label.text = _format_trend(docked_star.trend)

	credits_label.text = "$: " + str(game_manager.credits)
	cargo_label.text = "Cargo: " + str(game_manager.cargo)
	fuel_label.text = "Fuel: " + str(game_manager.fuel)

	buy_qty_label.text = str(buy_quantity)
	sell_qty_label.text = str(sell_quantity)
	buy_total_label.text = "Total: $" + str(buy_quantity * docked_star.current_price)
	sell_total_label.text = "Total: $" + str(sell_quantity * get_sell_unit_price())

	buy_btn.disabled = buy_quantity <= 0
	sell_btn.disabled = sell_quantity <= 0


func get_sell_unit_price() -> int:
	if docked_star == null:
		return 0
	return int(docked_star.current_price * docked_star.sell_percentage)


func get_max_buy_qty() -> int:
	if docked_star == null or docked_star.current_price <= 0:
		return 0
	return clampi(game_manager.credits / docked_star.current_price, 0, game_manager.stats["cargo_max"])


func get_max_sell_qty() -> int:
	return game_manager.cargo


func _format_trend(trend: int) -> String:
	if trend > 0:
		return "⭧ +" + str(trend)
	elif trend < 0:
		return "⭨ " + str(trend)
	return "⭢ " + str(trend)


func _set_buy_quantity(qty: int) -> void:
	buy_quantity = clampi(qty, 0, get_max_buy_qty())
	refresh()


func _set_sell_quantity(qty: int) -> void:
	sell_quantity = clampi(qty, 0, get_max_sell_qty())
	refresh()


func _add_buy_quantity(amount: int) -> void:
	_set_buy_quantity(buy_quantity + amount)


func _add_sell_quantity(amount: int) -> void:
	_set_sell_quantity(sell_quantity + amount)


func _on_buy_minus() -> void:
	_set_buy_quantity(buy_quantity - 1)


func _on_buy_plus() -> void:
	_set_buy_quantity(buy_quantity + 1)


func _on_sell_minus() -> void:
	_set_sell_quantity(sell_quantity - 1)


func _on_sell_plus() -> void:
	_set_sell_quantity(sell_quantity + 1)


func _on_buy_pressed() -> void:
	if docked_star == null or buy_quantity <= 0:
		return
	var cost = buy_quantity * docked_star.current_price
	game_manager.buy_or_sell(-cost, buy_quantity)
	buy_quantity = 0
	sell_quantity = 0
	refresh()


func _on_sell_pressed() -> void:
	if docked_star == null or sell_quantity <= 0:
		return
	var revenue := sell_quantity * get_sell_unit_price()
	game_manager.buy_or_sell(revenue, -sell_quantity)
	buy_quantity = 0
	sell_quantity = 0
	refresh()


func _on_leave_pressed() -> void:
	visible = false
	docked_star = null
	buy_quantity = 0
	sell_quantity = 0
	left_market.emit()
