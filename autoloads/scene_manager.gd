extends Node
## Single place that owns scene flow: menu -> explore -> fight ->
## post-fight dialogue -> explore.
##
## Scenes never call change_scene_to_file() themselves; they call
## SceneManager.goto() (or start_fight/return_from_fight) so the transition,
## the fade, and the hand-off payload all live in one file.

const SCENES := {
	"menu": "res://scenes/ui/main_menu.tscn",
	"menu2": "res://scenes/ui/main_menu_2.tscn",
	"explore": "res://scenes/world/explore_area.tscn",
	"fight": "res://scenes/fight/fight_scene.tscn",
}

const FADE_TIME := 0.35

signal scene_changed(scene_key: String)

## Data handed to the incoming scene. Read it once with consume_payload().
var _payload: Dictionary = {}
var _current_key: String = ""
var _busy := false

var _fade_layer: CanvasLayer
var _fade_rect: ColorRect


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_fade_overlay()


func _build_fade_overlay() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 128
	add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.visible = false
	_fade_layer.add_child(_fade_rect)


func current_scene_key() -> String:
	return _current_key


## Read (and clear) the data passed by whoever requested this scene.
func consume_payload() -> Dictionary:
	var data := _payload
	_payload = {}
	return data


## Peek without clearing — useful for debugging.
func peek_payload() -> Dictionary:
	return _payload


func goto(scene_key: String, payload: Dictionary = {}, fade: bool = true) -> void:
	if not SCENES.has(scene_key):
		push_error("SceneManager: unknown scene key '%s'" % scene_key)
		return
	if _busy:
		return
	_busy = true
	_payload = payload
	_current_key = scene_key

	if fade:
		await _fade_to(1.0)

	var err := get_tree().change_scene_to_file(SCENES[scene_key])
	if err != OK:
		push_error("SceneManager: failed to load '%s' (error %d)" % [scene_key, err])
		_busy = false
		await _fade_to(0.0)
		return

	# Let the new scene run _ready() before revealing it.
	await get_tree().process_frame
	scene_changed.emit(scene_key)

	if fade:
		await _fade_to(0.0)
	_busy = false


## Explore -> fight. `context` describes the encounter and how to get back.
func start_fight(context: Dictionary) -> void:
	var payload := context.duplicate(true)
	payload["return_scene"] = payload.get("return_scene", "explore")
	goto("fight", payload)


## Fight (and its post-fight dialogue) -> wherever we came from.
func return_from_fight(result: Dictionary) -> void:
	GameState.last_fight_result = result.duplicate(true)
	var back: String = str(result.get("return_scene", "explore"))
	goto(back, {"from": "fight", "result": result.duplicate(true)})


func quit_game() -> void:
	get_tree().quit()


func _fade_to(target_alpha: float) -> void:
	_fade_rect.visible = true
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", target_alpha, FADE_TIME)
	await tween.finished
	if is_equal_approx(target_alpha, 0.0):
		_fade_rect.visible = false
