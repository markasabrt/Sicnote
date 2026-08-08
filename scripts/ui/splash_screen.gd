extends Control
## Title card. Fades in, holds, hands off to the main menu. Any key skips.

@export var fade_in := 0.8
@export var hold := 1.1
@export var fade_out := 0.6

@onready var _title: Label = $Center/Title
@onready var _subtitle: Label = $Center/Subtitle

var _leaving := false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_title.modulate.a = 0.0
	_subtitle.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(_title, "modulate:a", 1.0, fade_in)
	tween.parallel().tween_property(_subtitle, "modulate:a", 0.7, fade_in)
	tween.tween_interval(hold)
	tween.tween_callback(_leave)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		_leave()


func _leave() -> void:
	if _leaving:
		return
	_leaving = true
	SceneManager.goto("menu")
