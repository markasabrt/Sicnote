extends Node3D
## Main menu as a physical object: a cube you grab and spin with the mouse, one
## option per face, rather than a flat list of buttons (TECH_DECISIONS.md,
## "First vertical slice scope").
##
## Whichever face is turned toward the camera is the selected option.

const OPTION_COUNT := 4
## Indexed by the quarter-turn the pivot is closest to. Rotating +90 degrees
## about Y brings the -X face to the camera, then -Z, then +X.
const OPTIONS := ["NEW GAME", "CONTINUE", "CREDITS", "QUIT"]
const OPTION_IDS := ["new_game", "continue", "credits", "quit"]

@export var drag_sensitivity := 0.006
## How fast the cube settles onto the nearest face when released.
@export var snap_speed := 7.0

@onready var _pivot: Node3D = $Pivot
@onready var _selection_label: Label = $HUD/Selection
@onready var _hint_label: Label = $HUD/Hint
@onready var _credits_label: Label = $HUD/Credits
@onready var _blips: BlipPlayer = $Blips

var _dragging := false
var _drag_distance := 0.0
var _selected := 0
var _voice: NoteVoice


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_voice = Speakers.voice_for("misa")
	_credits_label.visible = false
	_hint_label.text = "drag to turn · Enter to choose"
	_update_selection(true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu_grab"):
		_dragging = true
		_drag_distance = 0.0
	elif event.is_action_released("menu_grab"):
		_dragging = false
		# A click that didn't really drag counts as choosing the front face.
		if _drag_distance < 6.0:
			_confirm()
	elif event is InputEventMouseMotion and _dragging:
		var motion := event as InputEventMouseMotion
		_drag_distance += motion.relative.length()
		# The cube follows the cursor: drag right and the object turns right,
		# bringing the face on its left round to the front.
		_pivot.rotation.y += motion.relative.x * drag_sensitivity
		_pivot.rotation.x = clampf(_pivot.rotation.x - motion.relative.y * drag_sensitivity, -0.35, 0.35)
	elif event.is_action_pressed("ui_accept"):
		_confirm()
	elif event.is_action_pressed("ui_right"):
		_step(-1)
	elif event.is_action_pressed("ui_left"):
		_step(1)


func _process(delta: float) -> void:
	if _dragging:
		_update_selection()
		return

	# Idle drift keeps the object alive; once it's near a face it snaps to it.
	var target_yaw := _selected * TAU / OPTION_COUNT
	var offset := wrapf(target_yaw - _pivot.rotation.y, -PI, PI)
	_pivot.rotation.y += offset * minf(snap_speed * delta, 1.0)
	_pivot.rotation.x = lerpf(_pivot.rotation.x, 0.0, minf(snap_speed * delta, 1.0))
	_update_selection()


func _step(direction: int) -> void:
	_selected = wrapi(_selected + direction, 0, OPTION_COUNT)
	_pivot.rotation.y = _selected * TAU / OPTION_COUNT
	_refresh_label(true)


func _update_selection(force: bool = false) -> void:
	var quarter := wrapi(int(round(_pivot.rotation.y / (TAU / OPTION_COUNT))), 0, OPTION_COUNT)
	if quarter != _selected or force:
		_selected = quarter
		_refresh_label(not force)


func _refresh_label(blip: bool) -> void:
	_selection_label.text = OPTIONS[_selected]
	var can_continue := _selected != 1 or GameState.has_save()
	_selection_label.modulate = Color(1, 1, 1) if can_continue else Color(1, 1, 1, 0.4)
	if blip:
		_blips.play_voice(_voice)


func _confirm() -> void:
	match OPTION_IDS[_selected]:
		"new_game":
			GameState.reset()
			SceneManager.goto("explore")
		"continue":
			if GameState.load_game():
				SceneManager.goto("explore")
			else:
				_hint_label.text = "no save yet"
		"credits":
			_credits_label.visible = not _credits_label.visible
		"quit":
			SceneManager.quit_game()
