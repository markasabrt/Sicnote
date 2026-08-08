extends Node
## Global, persistent game state.
##
## This is the single source of truth for everything the save system persists
## (see "Save system" in docs/design/TECH_DECISIONS.md): ink total, level,
## trait allocation, story flags, inventory, and world state.
##
## The vertical slice already writes here (fights award ink, defeated enemies
## are recorded in world state), so the *shape* matters now even though most of
## it isn't surfaced to the player yet.

const SAVE_PATH := "user://sicnote_save.json"
const SAVE_VERSION := 1

## Ink needed for the next level: 100, 150, 200, ... Levelling is the sigil
## spreading, not a generic XP curve — see TECH_DECISIONS.md.
const INK_BASE_COST := 100
const INK_COST_PER_LEVEL := 50
## Level at which the sigil has fully spread (and, in fiction, consumed Misa).
const MAX_LEVEL := 20

## The three traits the in-fiction second book describes.
const TRAITS := ["perception", "acrobatics", "strength"]

signal ink_gained(amount: int, total: int)
## Emitted only at the moment of level-up. Deliberately the *only* progression
## feedback the player gets — ink accumulates silently in between.
signal leveled_up(new_level: int, sigil_spread: float)
signal state_loaded()

# --- Progression ---------------------------------------------------------
var ink_total: int = 0        ## Lifetime ink. Never decreases; drives consumption.
var ink_progress: int = 0     ## Ink banked toward the next level (not surfaced live).
var level: int = 1
var trait_points_unspent: int = 0
var traits: Dictionary = {"perception": 0, "acrobatics": 0, "strength": 0}

# --- Story / world -------------------------------------------------------
var story_flags: Dictionary = {}   ## flag_name -> bool/int/String
var inventory: Array[String] = []  ## item ids; equippable outfit pieces
var equipped: Dictionary = {}      ## slot -> item id
var world_state: Dictionary = {}   ## e.g. "encounter.alley_runner.defeated" -> true

# --- Session-only (not saved) -------------------------------------------
var last_fight_result: Dictionary = {}


func _ready() -> void:
	reset()


func reset() -> void:
	ink_total = 0
	ink_progress = 0
	level = 1
	trait_points_unspent = 0
	traits = {"perception": 0, "acrobatics": 0, "strength": 0}
	story_flags.clear()
	inventory.clear()
	equipped.clear()
	world_state.clear()
	last_fight_result.clear()


# --- Progression API -----------------------------------------------------

func ink_for_level(target_level: int) -> int:
	return INK_BASE_COST + (target_level - 1) * INK_COST_PER_LEVEL


## How far the sigil has visibly spread across Misa's back, 0..1.
## Tied to level, not raw ink — the spread is a reveal, not a live meter.
func sigil_spread() -> float:
	return clampf(float(level - 1) / float(MAX_LEVEL - 1), 0.0, 1.0)


## Award ink earned by rhythm-fight performance. Returns how many levels it
## caused (usually 0 or 1).
func add_ink(amount: int) -> int:
	if amount <= 0:
		return 0
	ink_total += amount
	ink_progress += amount
	ink_gained.emit(amount, ink_total)

	var levels_gained := 0
	while level < MAX_LEVEL and ink_progress >= ink_for_level(level):
		ink_progress -= ink_for_level(level)
		level += 1
		levels_gained += 1
		trait_points_unspent += 1
		leveled_up.emit(level, sigil_spread())
	return levels_gained


func spend_trait_point(trait_name: String) -> bool:
	if trait_points_unspent <= 0 or not traits.has(trait_name):
		return false
	trait_points_unspent -= 1
	traits[trait_name] = int(traits[trait_name]) + 1
	return true


# --- Flags / world -------------------------------------------------------

func set_flag(flag: String, value: Variant = true) -> void:
	story_flags[flag] = value


func get_flag(flag: String, default_value: Variant = false) -> Variant:
	return story_flags.get(flag, default_value)


func set_world(key: String, value: Variant) -> void:
	world_state[key] = value


func get_world(key: String, default_value: Variant = false) -> Variant:
	return world_state.get(key, default_value)


func add_item(item_id: String) -> void:
	if not inventory.has(item_id):
		inventory.append(item_id)


# --- Save / load ---------------------------------------------------------

func to_dict() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"ink_total": ink_total,
		"ink_progress": ink_progress,
		"level": level,
		"trait_points_unspent": trait_points_unspent,
		"traits": traits.duplicate(true),
		"story_flags": story_flags.duplicate(true),
		"inventory": Array(inventory),
		"equipped": equipped.duplicate(true),
		"world_state": world_state.duplicate(true),
	}


func from_dict(data: Dictionary) -> void:
	reset()
	ink_total = int(data.get("ink_total", 0))
	ink_progress = int(data.get("ink_progress", 0))
	level = int(data.get("level", 1))
	trait_points_unspent = int(data.get("trait_points_unspent", 0))
	for trait_name in TRAITS:
		traits[trait_name] = int(data.get("traits", {}).get(trait_name, 0))
	story_flags = data.get("story_flags", {}).duplicate(true)
	equipped = data.get("equipped", {}).duplicate(true)
	world_state = data.get("world_state", {}).duplicate(true)
	inventory.clear()
	for item_id in data.get("inventory", []):
		inventory.append(str(item_id))
	state_loaded.emit()


func save_game() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file for writing: %s" % SAVE_PATH)
		return false
	file.store_string(JSON.stringify(to_dict(), "\t"))
	file.close()
	return true


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func load_game() -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Save file is malformed: %s" % SAVE_PATH)
		return false
	from_dict(parsed)
	return true
