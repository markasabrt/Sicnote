class_name EncounterTrigger
extends Area3D
## A hypnotized note standing in the 3D world. Touching it hands off to the
## dedicated 2D fight scene — a hard swap, not an overlay
## (TECH_DECISIONS.md, "Scene architecture").

## Stable id used for the world-state flag, so a defeated enemy stays defeated
## across a save/load.
@export var encounter_key: String = "encounter.alley_runner"
## Speaker id from the Speakers registry — decides their voice in dialogue.
@export var enemy_id: String = "runner"
## Their note duration in beats. Drives how dense the generated chart is.
@export var enemy_note_beats: float = 0.125
@export var chart_length_beats: float = 32.0
@export var chart_seed: int = 20250808
## Fights don't start the instant the scene loads under the player's feet.
@export var arm_delay: float = 0.4

var _armed := false
var _triggered := false


func _ready() -> void:
	if GameState.get_world(encounter_key + ".defeated", false):
		queue_free()
		return
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(arm_delay).timeout
	_armed = true


func _on_body_entered(body: Node3D) -> void:
	if _triggered or not _armed:
		return
	if not body.is_in_group("player"):
		return
	_triggered = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	SceneManager.start_fight({
		"encounter_key": encounter_key,
		"enemy_id": enemy_id,
		"enemy_note_beats": enemy_note_beats,
		"chart_length_beats": chart_length_beats,
		"chart_seed": chart_seed,
		"return_scene": "explore",
	})
