class_name DialogueBox
extends CanvasLayer
## Undertale-style dialogue: text scrolls one character at a time and each
## character "speaks" by blipping their own musical note
## (TECH_DECISIONS.md, "Dialogue delivery (interim)").
##
## The scroll speed *is* the note duration, so a 64th note visibly and audibly
## chatters where a whole note plods. That's the vertical slice's success
## criterion, and it's why speed and pitch both come from one value.

signal line_started(speaker_id: String)
signal finished()

## Blips are skipped on whitespace and (mostly) on punctuation so speech has
## natural gaps instead of a flat machine-gun tone.
const SILENT_CHARS := " \t\n.,!?…-'\""

@export var advance_actions: PackedStringArray = ["ui_accept", "interact"]

@onready var _root: Control = $Root
@onready var _speaker_label: Label = $Root/Panel/Margin/Lines/Speaker
@onready var _text_label: RichTextLabel = $Root/Panel/Margin/Lines/Text
@onready var _indicator: Label = $Root/Panel/Indicator
@onready var _blips: BlipPlayer = $Blips

var _lines: Array = []
var _index := -1
var _voice: NoteVoice
var _char_timer := 0.0
var _char_interval := 0.05
var _typing := false
var _active := false


func _ready() -> void:
	hide_box()
	set_process(false)
	set_process_unhandled_input(false)


## `lines` is an array of { "speaker": id, "text": String }.
func play(lines: Array) -> void:
	_lines = lines
	_index = -1
	_active = true
	_root.visible = true
	set_process(true)
	set_process_unhandled_input(true)
	_advance()


func hide_box() -> void:
	_root.visible = false
	_active = false


func is_active() -> bool:
	return _active


func _advance() -> void:
	_index += 1
	if _index >= _lines.size():
		_finish()
		return

	var line: Dictionary = _lines[_index]
	var speaker_id := str(line.get("speaker", "narrator"))
	_voice = Speakers.voice_for(speaker_id)
	_char_interval = _voice.blip_period()

	_speaker_label.text = Speakers.display_name(speaker_id)
	_speaker_label.visible = _speaker_label.text != ""
	_text_label.text = str(line.get("text", ""))
	_text_label.visible_characters = 0
	_char_timer = 0.0
	_typing = true
	_indicator.visible = false
	line_started.emit(speaker_id)


func _finish() -> void:
	hide_box()
	set_process(false)
	set_process_unhandled_input(false)
	finished.emit()


func _process(delta: float) -> void:
	if not _typing:
		return
	_char_timer += delta
	# Catch up in a loop so very fast voices aren't capped by the frame rate.
	while _typing and _char_timer >= _char_interval:
		_char_timer -= _char_interval
		_reveal_next_char()


func _reveal_next_char() -> void:
	var full := _text_label.get_parsed_text()
	if _text_label.visible_characters >= full.length():
		_stop_typing()
		return

	var next_char := full.substr(_text_label.visible_characters, 1)
	_text_label.visible_characters += 1
	if not SILENT_CHARS.contains(next_char):
		_blips.play_voice(_voice)

	if _text_label.visible_characters >= full.length():
		_stop_typing()


func _stop_typing() -> void:
	_typing = false
	_indicator.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if not _active or not event.is_pressed() or event.is_echo():
		return
	for action in advance_actions:
		if event.is_action_pressed(action):
			get_viewport().set_input_as_handled()
			if _typing:
				# First press dumps the rest of the line, second advances.
				_text_label.visible_characters = -1
				_stop_typing()
			else:
				_advance()
			return
