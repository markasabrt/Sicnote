extends Node2D
## The 2D rhythm fight. Entered by a hard scene swap out of the 3D exploration
## scene (TECH_DECISIONS.md, "Scene architecture").
##
## Beating a hypnotized fast note means out-pacing them: 90% accuracy frees
## them from tyrannical hypnosis and they pass out (GAME_DESIGN.md, "Fighting").

const DialogueBoxScene := preload("res://scenes/dialogue/dialogue_box.tscn")

@onready var _conductor: Conductor = $Conductor
@onready var _field: NoteField = $NoteField
@onready var _blips: BlipPlayer = $Blips
@onready var _enemy_label: Label = $HUD/Top/EnemyName
@onready var _accuracy_label: Label = $HUD/Top/Accuracy
@onready var _combo_label: Label = $HUD/Combo
@onready var _grade_label: Label = $HUD/Grade
@onready var _countdown_label: Label = $HUD/Countdown

var _chart: RhythmChart
var _context: Dictionary = {}

var _earned_weight := 0.0
var _judged_count := 0
var _combo := 0
var _best_combo := 0
var _resolved := false

var _misa_voice: NoteVoice
var _tick_stream: AudioStreamWAV
var _miss_stream: AudioStreamWAV


func _ready() -> void:
	_context = SceneManager.consume_payload()
	if _context.is_empty():
		# Running the fight scene directly from the editor (F6) — fake an
		# encounter so it's playable in isolation.
		_context = {
			"enemy_id": "runner",
			"enemy_note_beats": Speakers.THIRTY_SECOND,
			"return_scene": "explore",
		}

	_misa_voice = Speakers.voice_for("misa")
	_tick_stream = NoteVoice.synthesize(880.0, 0.03, NoteVoice.Wave.TRIANGLE, 0.18)
	_miss_stream = NoteVoice.synthesize(110.0, 0.12, NoteVoice.Wave.SQUARE, 0.35)

	_enemy_label.text = Speakers.display_name(str(_context.get("enemy_id", "runner")))
	_grade_label.text = ""
	_combo_label.text = ""
	_update_accuracy_label()

	_build_chart()
	_field.setup(_chart, _conductor)
	_field.position = Vector2((get_viewport_rect().size.x - _field.field_width()) * 0.5, 0.0)

	_field.note_judged.connect(_on_note_judged)
	_field.note_missed.connect(_on_note_missed)
	_field.chart_finished.connect(_on_chart_finished)
	_conductor.beat_hit.connect(_on_beat)

	_conductor.bpm = _chart.bpm
	_conductor.lead_in_beats = _chart.lead_in_beats

	# The fight opens on dialogue, so the two note values get heard back to
	# back — the enemy's 32nd, then Misa's 64th — before a single note falls.
	_play_intro_dialogue()


func _build_chart() -> void:
	var supplied: Variant = _context.get("chart")
	if supplied is RhythmChart:
		_chart = supplied
		_chart.ensure_notes()
		return
	# No authored chart: generate one from the opponent's note value. Real
	# charts arrive with real music, which is the other developer's domain.
	_chart = RhythmChart.for_enemy(
		float(_context.get("enemy_note_beats", Speakers.THIRTY_SECOND)),
		float(_context.get("chart_length_beats", 32.0)),
		int(_context.get("chart_seed", 20250808))
	)


func _play_intro_dialogue() -> void:
	var box: DialogueBox = DialogueBoxScene.instantiate()
	add_child(box)
	# One-shot: the connection holds a reference back to this scene, and
	# dropping it on emit is what keeps the box from leaking.
	box.finished.connect(_on_intro_finished.bind(box), CONNECT_ONE_SHOT)
	box.play(_intro_lines())


func _on_intro_finished(box: DialogueBox) -> void:
	box.queue_free()
	_conductor.start()


func _intro_lines() -> Array:
	var enemy_id := str(_context.get("enemy_id", "runner"))
	return [
		{
			"speaker": enemy_id,
			"text": "I am hypnotized but don't know this. Wait, then I shouldn't've said that. According to the script, we now have to fight in a rhythm based note game",
		},
		{"speaker": "misa", "text": "Uhh... who are we to argue with the script?"},
	]


func _process(_delta: float) -> void:
	if _conductor.running and _conductor.song_position < 0.0:
		var beats_left := int(ceil(-_conductor.song_position_beats))
		_countdown_label.text = str(beats_left)
	elif _countdown_label.text != "":
		_countdown_label.text = ""


func _on_beat(beat_index: int) -> void:
	# Metronome during the lead-in only — enough to find the tempo without
	# fighting the (eventual) music track.
	if beat_index < 0:
		_blips.play_stream(_tick_stream)


func _on_note_judged(grade: int, _lane: int, _timing_error: float) -> void:
	_earned_weight += Judgement.weight(grade)
	_judged_count += 1

	if grade == Judgement.Grade.MISS:
		_break_combo()
	else:
		_combo += 1
		_best_combo = maxi(_best_combo, _combo)
		# Misa's own note fires on every clean hit — the player hears exactly
		# how fast she is while playing her.
		_blips.play_voice(_misa_voice)

	_show_grade(Judgement.grade_name(grade))
	_update_accuracy_label()


func _on_note_missed(_lane: int) -> void:
	_judged_count += 1
	_break_combo()
	_blips.play_stream(_miss_stream)
	_show_grade("MISS")
	_update_accuracy_label()


func _break_combo() -> void:
	_combo = 0


func _show_grade(text: String) -> void:
	_grade_label.text = text
	_combo_label.text = ("%d COMBO" % _combo) if _combo > 1 else ""


func _current_accuracy() -> float:
	return Judgement.accuracy(_earned_weight, _field.total_notes())


func _update_accuracy_label() -> void:
	# Accuracy is shown against the whole chart, so it climbs toward its final
	# value rather than starting at 100% and only ever falling.
	_accuracy_label.text = "%.1f%%  (need %d%%)" % [
		_current_accuracy() * 100.0,
		int(Judgement.WIN_ACCURACY * 100.0),
	]


func _on_chart_finished() -> void:
	if _resolved:
		return
	_resolved = true
	_conductor.finish()

	var accuracy := _current_accuracy()
	var won := accuracy >= Judgement.WIN_ACCURACY
	var ink := Judgement.ink_reward(accuracy, won)
	var levels := GameState.add_ink(ink) if won else 0

	if won:
		var enemy_key := str(_context.get("encounter_key", ""))
		if enemy_key != "":
			GameState.set_world(enemy_key + ".defeated", true)

	_grade_label.text = "FREED" if won else "NOT FAST ENOUGH"
	_countdown_label.text = ""

	var result := {
		"won": won,
		"accuracy": accuracy,
		"best_combo": _best_combo,
		"ink": ink if won else 0,
		"levels_gained": levels,
		"return_scene": str(_context.get("return_scene", "explore")),
		"encounter_key": _context.get("encounter_key", ""),
	}

	await get_tree().create_timer(0.8).timeout
	_play_post_fight_dialogue(result)


func _play_post_fight_dialogue(result: Dictionary) -> void:
	var box: DialogueBox = DialogueBoxScene.instantiate()
	add_child(box)
	box.finished.connect(_on_post_fight_finished.bind(result), CONNECT_ONE_SHOT)
	box.play(_post_fight_lines(result))


func _on_post_fight_finished(result: Dictionary) -> void:
	SceneManager.return_from_fight(result)


func _post_fight_lines(result: Dictionary) -> Array:
	var enemy_id := str(_context.get("enemy_id", "runner"))
	if result["won"]:
		return [
			{"speaker": enemy_id, "text": "...how. Nobody keeps up with me. Nobody."},
			{"speaker": "misa", "text": "You weren't running. Something was running you."},
			{"speaker": enemy_id, "text": "It's quiet now. It's been so loud for so long."},
			{"speaker": "misa", "text": "Rest. I'll find where it's coming from."},
		]
	return [
		{"speaker": enemy_id, "text": "Too slow. Too slow. Too slow."},
		{"speaker": "misa", "text": "Then I'll be faster. I have to be."},
	]
