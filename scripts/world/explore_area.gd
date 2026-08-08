extends Node3D
## The small 3D exploration area for the vertical slice: walk around, touch the
## hypnotized note, get thrown into the fight, come back here afterwards.

@onready var _player: PlayerExplorer = $Player
@onready var _banner: Label = $HUD/Banner
@onready var _hint: Label = $HUD/Hint

## Where the player stands when returning from a fight — just outside where the
## enemy was, so they don't immediately re-trigger it.
@export var post_fight_spawn := Vector3(0.0, 1.2, 6.0)


func _ready() -> void:
	var payload := SceneManager.consume_payload()
	_banner.text = ""

	if str(payload.get("from", "")) == "fight":
		_player.global_position = post_fight_spawn
		_show_fight_result(payload.get("result", {}))

	_hint.text = "WASD move · mouse look · Esc free cursor"


func _show_fight_result(result: Dictionary) -> void:
	if result.is_empty():
		return
	var accuracy := float(result.get("accuracy", 0.0)) * 100.0
	if bool(result.get("won", false)):
		_banner.text = "%.1f%% — freed. +%d ink" % [accuracy, int(result.get("ink", 0))]
		if int(result.get("levels_gained", 0)) > 0:
			# The only moment progression is ever surfaced: the sigil spread is
			# a reveal, not a live meter (TECH_DECISIONS.md).
			_banner.text += "\nThe ink spreads. Level %d." % GameState.level
	else:
		_banner.text = "%.1f%% — not fast enough." % accuracy

	await get_tree().create_timer(5.0).timeout
	if is_instance_valid(_banner):
		_banner.text = ""
