# MERCHANT KINGS - Complete Game Documentation
## A Comprehensive Guide to Perfect Replication

**Document Version:** 4.0  
**Last Updated:** March 2026  
**Godot Version:** 4.3  
**Main Scene:** `res://Game Scenes/galaxy_map.tscn`

---

## TABLE OF CONTENTS

1. [Project Overview](#project-overview)
2. [Project Structure](#project-structure)
3. [Project Configuration](#project-configuration)
4. [Scene Architecture](#scene-architecture)
5. [Play State Machine and Move Timer](#play-state-machine-and-move-timer)
6. [Script Documentation](#script-documentation)
7. [Resource Assets](#resource-assets)
8. [Game Mechanics](#game-mechanics)
9. [Market System](#market-system)
10. [User Interface System](#user-interface-system)
11. [Trading System](#trading-system)
12. [Upgrade Shop (Work in Progress)](#upgrade-shop-work-in-progress)
13. [Step-by-Step Replication Guide](#step-by-step-replication-guide)
14. [Technical Specifications](#technical-specifications)
15. [Changelog](#changelog)

---

## PROJECT OVERVIEW

**Merchant Kings** is a 2D space exploration and trading game. The player travels between procedurally generated star systems, trades goods at dynamic markets, pays sector mortgages, and tries to stay solvent.

### Core Features

- Procedural galaxy map (11 stars, 3 connections each)
- Click-to-move with fuel cost per hop
- **Full-screen market UI** (`market_screen.tscn`) — one shared screen per docked star
- **Idle star tooltips** (`idle_star_ui.tscn`) — price and trend on the map while routing
- **Move timer** — after leaving market, delay costs fuel and advances all markets
- **Play states:** DOCKED → DECIDING → MOVING
- Sector completion, mortgage payments, shop screen (upgrades WIP)
- `GameManager` autoload singleton

### Core Gameplay Loop

1. New sector: 1000 credits (persists), 6 fuel from `stats`, cargo reset to 0
2. Ship placed at Star1; **full-screen market opens** (DOCKED)
3. Player trades via market screen, then presses **Leave Market**
4. **DECIDING:** idle UIs on unvisited stars; **move timer** runs (default 10s)
5. Timer expiry: −1 fuel, all markets tick, timer **restarts**
6. Click connected unvisited neighbor: −1 fuel, ship moves (MOVING); idle UIs hidden
7. On arrival: market tick, market opens again (DOCKED)
8. **Finish Sector:** mortgage deducted; **Go To Store** opens shop (WIP)
9. Visited stars use `visited_star_image.png` and cannot be re-entered

### Mortgage Schedule

`sector_mortgages = [0, 700, 1000, 1300, 1600]` — index by `sector` after `sector += 1` in `start_sector()`. Sector 5+ uses 1600 (capped).

---

## PROJECT STRUCTURE

```
merchant-kings/
├── Game Scenes/
│   ├── galaxy_map.tscn           # Main scene
│   ├── game_manager.gd           # Autoload — state, timer, resources
│   ├── sector_generator.gd       # Procedural stars + idle UIs
│   ├── market_screen.tscn        # Full-screen trading UI
│   ├── market_screen.gd
│   ├── star_system.tscn          # Star Area2D + market simulation
│   ├── star_system.gd
│   ├── player_ship.tscn
│   ├── player_ship.gd
│   ├── idle_star_ui.tscn         # Map tooltips only
│   ├── hud.tscn                  # Resources + move timer label
│   ├── finish_sector_ui.tscn
│   ├── shop_ui.tscn              # Upgrade shop (WIP)
│   ├── shop_ui.gd                # Empty stub
│   ├── upgrade_ui.tscn           # Single upgrade card template
│   └── path_scene.tscn
├── upgrades.json                 # Upgrade definitions (WIP)
├── player_image.png
├── star_image.png
├── visited_star_image.png
├── star_path.png
├── icon.svg
├── Fonts/
├── project.godot
└── MERCHANT_KINGS_COMPLETE_DOCUMENTATION.md
```

**Removed:** `star_ui.tscn` (per-star floating market panels). Trading is only on `market_screen`.

**Renamed concept:** `StarUIContainer` → **`IdleUIContainer`** in `galaxy_map.tscn` (holds only `idle_star_ui` instances).

---

## PROJECT CONFIGURATION

### project.godot

```ini
config_version=5

[application]
config/name="Merchant Kings"
run/main_scene="res://Game Scenes/galaxy_map.tscn"
config/features=PackedStringArray("4.3", "Forward Plus")
config/icon="res://icon.svg"

[autoload]
GameManager="*res://Game Scenes/game_manager.gd"

[display]
window/size/viewport_width=1920
window/size/viewport_height=1080
window/size/mode=3
window/stretch/mode="viewport"

[rendering]
textures/canvas_textures/default_texture_filter=0
2d/snap/snap_2d_transforms_to_pixel=true
```

---

## SCENE ARCHITECTURE

### galaxy_map.tscn

```
GalaxyMap (Node2D)
├── PathContainer
├── StarContainer
├── PlayerShip (instance player_ship.tscn)
├── Camera2D (zoom 3, 3)
├── SectorGenerator (sector_generator.gd)
│   ├── num_stars = 11
│   ├── min_spacing = 100.0
│   └── num_connections = 3
└── CanvasLayer
    ├── Hud (z_index 1)
    ├── IdleUIContainer (mouse_filter Ignore)
    ├── FinishSectorUI (hidden, z_index 1)
    ├── ShopUI (hidden, z_index 1)
    └── MarketScreen (z_index 2)
```

### market_screen.tscn

Full-screen `Control` with script `market_screen.gd`.

```
MarketScreen
├── Panel (StyleBoxFlat dark bg)
└── MarginContainer / VBoxContainer
    ├── TitleLabel ("Market")
    ├── HeaderHBox: StarNameLabel, BuyPriceLabel, SellPriceLabel, TrendLabel
    ├── PlayerStatsHBox: CreditsLabel, CargoLabel, FuelLabel
    ├── HSeparator
    ├── TradeHBox
    │   ├── BuySection (green PanelContainer)
    │   │   └── QtyRow (-, qty, +)
    │   │   └── PresetRow: Buy5 (+5), Buy10 (+10), BuyMax, BuyReset
    │   │   └── BuyTotalLabel, BuyButton
    │   └── SellSection (brown PanelContainer)
    │       └── QtyRow, PresetRow: Sell5, Sell10, SellMax, SellReset
    │       └── SellTotalLabel, SellButton
    └── FooterHBox: LeaveButton ("Leave Market")
```

**Buy panel color:** `Color(0.564499, 0.622242, 0.528906, 1)`  
**Sell panel color:** `Color(0.462483, 0.39211, 0.355605, 1)`

### hud.tscn

- **HBoxContainer:** Credits, Fuel, Cargo (font 50)
- **Mortgage** label (top-right)
- **MoveTimerLabel** (center-top, yellow, hidden by default): `"Next move: Xs (or -1 Fuel)"`
- **FinishSectorButton** (bottom-right)

### idle_star_ui.tscn

Per-star tooltip on map: trend label (green) + cost label (black). Linked from `star.idle_ui`.

### finish_sector_ui.tscn / shop_ui.tscn

Finish sector overlay with score, mortgage, final credits, Go To Store / Game Over.  
Shop shows 4× `upgrade_ui` instances (logic not wired).

---

## PLAY STATE MACHINE AND MOVE TIMER

### PlayState enum (`game_manager.gd`)

```gdscript
enum PlayState { DOCKED, DECIDING, MOVING }
var play_state := PlayState.DOCKED
@export var move_timer_seconds := 10.0
```

| State | MarketScreen | Idle star UI | Move timer | Star clicks | Market tick |
|-------|--------------|--------------|------------|-------------|-------------|
| **DOCKED** | Visible | Hidden | Off | Ignored | On arrival |
| **DECIDING** | Hidden | Visible (unvisited) | Running | Valid move | On each timeout |
| **MOVING** | Hidden | Hidden | Off | Ignored | None |

### Flow diagram

```
Arrive at star → DOCKED (market open, tick markets)
Leave Market → DECIDING (timer start, idle UIs on)
Timer expires → −1 fuel, tick all markets, restart timer
Click neighbor → MOVING (−1 fuel, hide idle UIs)
Arrive → DOCKED again
```

### Timer implementation

- `Timer` node created in `GameManager._ready()`, `one_shot = true`
- `_start_move_timer()` on `market_screen.left_market`
- `_on_move_timer_timeout()`: if `fuel <= 0`, stop; else `fuel -= 1`, `advance_market_tick()`, `_refresh_all_idle_labels()`, restart timer
- `_stop_move_timer()` on valid move, finish sector, shop, reset
- `_process()` updates `MoveTimerLabel` with `ceil(move_timer.time_left)`

### Idle UI visibility (`_set_idle_ui_visibility`)

- **DOCKED / MOVING:** all hidden
- **DECIDING:** visible only on stars where `not star.visited`

---

## SCRIPT DOCUMENTATION

### game_manager.gd (Autoload)

**Global variables:**

```gdscript
var stats = {"fuel": 6, "starting_credits": 0}
var sector := 0
var sector_mortgages := [0, 700, 1000, 1300, 1600]
var current_mortgage := 0
var fuel: int
var credits := 1000
var cargo := 0
var play_state := PlayState.DOCKED
var stars = []
var current_star: Object
var move_timer: Timer
```

**Key node paths:**

| Variable | Path |
|----------|------|
| idle_ui_container | `/root/GalaxyMap/CanvasLayer/IdleUIContainer` |
| market_screen | `/root/GalaxyMap/CanvasLayer/MarketScreen` |
| move_timer_label | `.../Hud/MoveTimerLabel` |
| shop_ui | `/root/GalaxyMap/CanvasLayer/ShopUI` |

**`start_sector()`**

1. `sector += 1`; set `current_mortgage` (capped at array end)
2. `fuel = stats["fuel"]`; `cargo = 0`; `credits += stats["starting_credits"]`
3. Update HUD labels
4. `SECTOR_GENERATOR.GenerateSector()`
5. Position ship at Star1 − 20px X
6. Connect `star_pressed` on each star; `init_market(50, 0.80, 0, 0.50, 2, 20, 100, 3)`
7. **`arrived_at_star(star1)`** — opens market immediately

**`star_pressed(star)`** — only if `play_state == DECIDING`

- Valid: not moving, not visited, not current, `fuel > 0`, neighbor
- Stop timer; `MOVING`; hide idle UIs; disable finish button
- −1 fuel; mark current visited + texture; `SHIP.start_movement`

**`arrived_at_star(star)`**

- `DOCKED`; stop timer; hide idle UIs
- `advance_market_tick()`; `market_screen.open(star)`

**`_on_left_market()`** — connected to `market_screen.left_market`

- `DECIDING`; show idle UIs; start move timer

**`buy_or_sell(cost, amount)`** — called from `market_screen.gd`

- Rejects if credits or cargo would go negative
- Updates HUD credit/cargo labels

**`finish_sector()`** — stops timer; hides market + HUD; shows finish UI; deducts mortgage

**`open_store()`** — stops timer; shows shop (does not yet call `reset_map` / `start_sector`)

**`reset_map()`** — frees stars, paths, idle UI children; clears `stars` array

---

### market_screen.gd

**Signal:** `left_market`

**State:** `docked_star`, `buy_quantity`, `sell_quantity`

**Preset buttons (buy and sell):**

| Button | Action |
|--------|--------|
| **+5** | `_add_*_quantity(5)` — stacks |
| **+10** | `_add_*_quantity(10)` — stacks |
| **Max** | Set to max affordable / all cargo |
| **Reset** | Set quantity to 0 |
| **− / +** | ±1 |
| **Buy / Sell** | Execute trade, reset quantities |

**Pricing:**

- Buy unit: `docked_star.current_price`
- Sell unit: `int(current_price * sell_percentage)` — default 80%

**`open(star)`** — sets `docked_star`, resets quantities, `visible = true`, `refresh()`

**`refresh()`** — updates all labels; disables Buy/Sell if quantity 0

**`_on_leave_pressed()`** — hides screen, emits `left_market`

---

### star_system.gd

**Signals:** `star_pressed(star)` only (no `buy_or_sell`)

**UI:** `idle_ui`, `idle_ui_panel`, `market_trend_label`, `market_cost_label`

**Market vars:** `base_price`, `sell_percentage`, `current_price`, `trend`, `trend_strength`, `volatility`, `minimum`, `maximum`

**`init_market(...)`** — sets params; random initial trend; `current_price += randfn(0,10)`; clamp; wire idle labels; `refresh_idle_labels()`

**`update_market()`** — trend ± volatility; `current_price += trend`; clamp; `refresh_idle_labels()`

**`refresh_idle_labels()`** — updates idle tooltip trend (⭧/⭨/⭢) and price

**`_on_input_event`** — left click → `star_pressed`

---

### sector_generator.gd

**Preloads:** `star_system.tscn`, `path_scene.tscn`, `idle_star_ui.tscn`  
**Container:** `IdleUIContainer` (not StarUIContainer)

**Per star:**

1. Instantiate star at random position (x: −276..276, y: −156..−125)
2. Instantiate `idle_star_ui`; position = canvas transform × world pos
3. Link `star.idle_ui`, `star.idle_ui_panel`; start hidden

**Connections:** each star ↔ 3 nearest neighbors; `Line2D` paths

**No** `star_ui`, **no** `check_ui_position()`

---

### player_ship.gd

**Signal:** `arrived_at_star(star)`

Movement: acceleration/deceleration, `lerp_angle` rotation, distance-based speed, stops within 1px and low velocity.

---

## RESOURCE ASSETS

| File | Usage |
|------|--------|
| `player_image.png` | Ship sprite |
| `star_image.png` | Unvisited star |
| `visited_star_image.png` | Visited star (applied in `star_pressed`) |
| `star_path.png` | Line2D connection texture (tiled) |
| `icon.svg` | Project icon |
| `Fonts/Merriweather_*` | UI typography (optional on labels) |

---

## GAME MECHANICS

### Fuel

- Start: `stats["fuel"]` (default 6) each sector
- −1 per successful hop to neighbor
- −1 per move timer timeout (can repeat)
- At 0 fuel in DECIDING: timer stops; message "Out of fuel — Finish Sector"; must finish sector

### Credits and cargo

- Start 1000 credits; persist across sectors (minus mortgage)
- `stats["starting_credits"]` added each sector start (upgrade hook)
- Cargo resets to 0 each sector

### Visited stars

- `visited = true`; texture swap; cannot click again
- Idle UI hidden for visited stars during DECIDING

### Sector finish

- Mortgage subtracted from credits
- If credits < 0: Game Over (no store button)
- Else: Go To Store → `shop_ui` (upgrade purchase not implemented)

---

## MARKET SYSTEM

Each star has independent market simulation in `star_system.gd`.

### Default init (`start_sector`)

```gdscript
star.init_market(50, 0.80, 0, 0.50, 2, 20, 100, 3)
```

| Param | Value | Meaning |
|-------|-------|---------|
| base_price | 50 | Reference |
| sell_percentage | 0.80 | Sell at 80% of buy |
| base_trend | 0 | Neutral bias |
| trend_strength | 0.50 | 50% up moves |
| volatility | 2 | Swing size |
| min / max | 20 / 100 | Price bounds |
| starting_diviation | 3 | Initial trend spread |

### update_market()

```gdscript
if rand.randf() > trend_strength:
    trend += -abs(int(rand.randfn(0, volatility)))
else:
    trend += abs(int(rand.randfn(0, volatility)))
current_price += trend
current_price = clampi(current_price, minimum, maximum)
```

### When markets tick

1. **On star arrival** (`arrived_at_star` → `advance_market_tick()`)
2. **On move timer timeout** (each expiry while DECIDING)

---

## USER INTERFACE SYSTEM

### Layer order (CanvasLayer z_index)

| z | Scene | Purpose |
|---|-------|---------|
| 0 | IdleUIContainer | Map tooltips |
| 1 | Hud, FinishSectorUI, ShopUI | HUD + overlays |
| 2 | MarketScreen | Full-screen market |

### HUD

Resources + mortgage + **move timer countdown** + finish button.

### Market screen

Primary trading UI; see [market_screen.gd](#market_screengd).

### Idle star UI

Shown during **DECIDING** on unvisited stars only. Displays price and trend for route planning.

### Finish / Shop

Standard overlays; shop uses `upgrade_ui.tscn` × 4.

---

## TRADING SYSTEM

All trading runs through **`market_screen.gd`** → **`GameManager.buy_or_sell(cost, amount)`**.

### Buy

```gdscript
cost = -(buy_quantity * current_price)
amount = buy_quantity
```

### Sell

```gdscript
cost = sell_quantity * int(current_price * sell_percentage)
amount = -sell_quantity
```

### Quantity controls

- **Stacking presets:** +5 and +10 add to current quantity (clamped to max)
- **Max:** `credits / price` (buy) or `cargo` (sell)
- **Reset:** quantity → 0
- After Buy/Sell confirm: quantities reset to 0

### Validation

- Buy max: `buy_quantity <= credits / current_price`
- Sell max: `sell_quantity <= cargo`
- Transaction: `(credits + cost) >= 0` and `(cargo + amount) >= 0`

---

## UPGRADE SHOP (WORK IN PROGRESS)

### upgrades.json

```json
[
    {"name": "Extra Fuel", "discription": "...", "effects": {"fuel": 1}},
    {"name": "Starting Credits", "discription": "...", "effects": {"starting_credits": 75}}
]
```

### game_manager.gd

`stats` dictionary applies upgrades:

- `fuel` from `stats["fuel"]` at sector start
- `credits += stats["starting_credits"]` each sector

**Not yet implemented:** loading JSON, populating shop UI, purchase flow, `reset_map()` + `start_sector()` after shop.

---

## STEP-BY-STEP REPLICATION GUIDE

### Phase 1: Project setup

1. Godot 4.3 project "Merchant Kings"
2. `project.godot` as above; autoload `GameManager` → `Game Scenes/game_manager.gd`
3. Main scene: `Game Scenes/galaxy_map.tscn`

### Phase 2: Assets

Place in project root: `player_image.png`, `star_image.png`, `visited_star_image.png`, `star_path.png`, `icon.svg`

### Phase 3: Core scenes

1. **path_scene.tscn** — Line2D, tiled texture  
2. **star_system.tscn** — Area2D + CircleShape2D r=6 + Sprite2D; script `star_system.gd`; connect `input_event`  
3. **player_ship.tscn** — Node2D + Sprite2D; script `player_ship.gd`  
4. **idle_star_ui.tscn** — tooltip layout (trend + cost labels)  
5. **galaxy_map.tscn** — containers, camera, sector generator, CanvasLayer children

### Phase 4: market_screen.tscn

1. Root `Control` full rect, script `market_screen.gd`
2. Dark full-screen Panel
3. Build VBox: header, stats, buy/sell sections with preset row **`+5`, `+10`, `Max`, `Reset`**
4. Leave Market button → will emit `left_market`
5. Instance in galaxy_map under CanvasLayer, `z_index = 2`

### Phase 5: HUD and overlays

1. **hud.tscn** — resource labels, Mortgage, **MoveTimerLabel**, FinishSectorButton  
2. **finish_sector_ui.tscn** — sector complete flow  
3. **shop_ui.tscn** — optional upgrade grid

### Phase 6: Scripts

Copy current versions of:

- `game_manager.gd` (PlayState, timer, market flow)
- `market_screen.gd` (trading + presets)
- `star_system.gd` (market sim + idle labels only)
- `sector_generator.gd` (idle UI only)
- `player_ship.gd`

### Phase 7: Wire signals

In `GameManager._ready()`:

```gdscript
SHIP.arrived_at_star.connect(arrived_at_star)
finish_sector_button.pressed.connect(finish_sector)
open_store_button.pressed.connect(open_store)
market_screen.left_market.connect(_on_left_market)
```

### Phase 8: Test checklist

- [ ] Market opens on sector start and each arrival  
- [ ] +5 / +10 stack quantity; Reset clears; Max fills  
- [ ] Sell uses 80% of buy price  
- [ ] Leave Market → timer + idle UIs  
- [ ] Timer −1 fuel + market tick + restart  
- [ ] Move −1 fuel; visited texture; no revisit  
- [ ] Finish sector / shop stops timer  
- [ ] No `star_ui` in project  

---

## TECHNICAL SPECIFICATIONS

- **Resolution:** 1920×1080, viewport stretch  
- **Stars per sector:** 11, min spacing 100, 3 connections  
- **Camera zoom:** 3×  
- **Signals:** `star_pressed`, `arrived_at_star`, `left_market`  
- **No save/load**

### Known limitations

- Shop upgrades not playable  
- `open_store()` does not advance to next sector yet  
- Out of fuel soft-lock (finish sector only)  
- Idle UI positions fixed at spawn (no camera follow)

---

## CHANGELOG

### Version 4.0 (March 2026)

- Full documentation rewrite for current codebase
- Documented **market_screen** (+5, +10, Max, Reset stacking presets)
- Documented **PlayState** and **move timer**
- Documented **IdleUIContainer** (replaces StarUIContainer)
- Removed all **star_ui** references
- Documented **sell_percentage** sell pricing
- Documented upgrade WIP (`stats`, `upgrades.json`)

### Version 3.0

- Full-screen market UI + move timer
- Removed per-star `star_ui.tscn`

### Earlier

- Mortgage system, finish sector UI, HUD, market simulation, sector generator

---

## CONCLUSION

Merchant Kings uses a single **MarketScreen** for all trading, **idle tooltips** for map scouting, and a **move timer** for urgency after undocking. `GameManager` coordinates `DOCKED` / `DECIDING` / `MOVING` states, fuel, mortgages, and market ticks.

Replicate by building scenes in the order above, copying the five core scripts, and verifying the Phase 8 checklist. Do **not** recreate `star_ui.tscn` — it has been removed from the design.

---

**End of Documentation**
