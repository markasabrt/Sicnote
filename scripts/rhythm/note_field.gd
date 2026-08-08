class_name NoteField
extends Node2D
## Draws the falling notes and turns key presses into judgements.
##
## Everything here is drawn primitively on purpose — sprite art belongs to the
## other developer (TECH_DECISIONS.md, "Asset Ownership"), so the fight has to
## be playable and tunable without it.

signal note_judged(grade: int, lane: int, timing_error: float)
signal note_missed(lane: int)
signal chart_finished()

const LANE_ACTIONS := [
	"rhythm_lane_1",
	"rhythm_lane_2",
	"rhythm_lane_3",
	"rhythm_lane_4",
]
const LANE_LABELS := ["D", "F", "J", "K"]

const LANE_COLORS := [
	Color("ff4d6d"),
	Color("ffd166"),
	Color("06d6a0"),
	Color("4cc9f0"),
]

@export var lane_width: float = 96.0
@export var lane_gap: float = 12.0
@export var hit_line_y: float = 560.0
## How long a note is on screen before it reaches the hit line.
@export var approach_seconds: float = 1.2
@export var scroll_distance: float = 620.0
@export var note_height: float = 22.0

var conductor: Conductor
var chart: RhythmChart

var _notes: Array[Dictionary] = []
var _first_live := 0          ## Notes below this index are resolved.
var _lane_flash: PackedFloat32Array = PackedFloat32Array()
var _finished := false


func _ready() -> void:
	_lane_flash.resize(RhythmChart.LANE_COUNT)
	_lane_flash.fill(0.0)
	set_process(false)
	set_process_unhandled_input(false)


func setup(chart_ref: RhythmChart, conductor_ref: Conductor) -> void:
	chart = chart_ref
	conductor = conductor_ref
	chart.ensure_notes()

	_notes.clear()
	_first_live = 0
	_finished = false
	var spb := 60.0 / maxf(chart.bpm, 1.0)
	for i in chart.note_count():
		_notes.append({
			"time": chart.note_beats[i] * spb,
			"lane": clampi(chart.note_lanes[i], 0, RhythmChart.LANE_COUNT - 1),
			"resolved": false,
		})

	set_process(true)
	set_process_unhandled_input(true)


func total_notes() -> int:
	return _notes.size()


func field_width() -> float:
	var count := RhythmChart.LANE_COUNT
	return count * lane_width + (count - 1) * lane_gap


func _lane_x(lane: int) -> float:
	return lane * (lane_width + lane_gap)


func _process(delta: float) -> void:
	for i in _lane_flash.size():
		_lane_flash[i] = maxf(_lane_flash[i] - delta * 4.0, 0.0)

	if conductor != null and conductor.running:
		_expire_missed_notes(conductor.song_position)
		_check_finished(conductor.song_position)
	queue_redraw()


## Notes that scrolled past the hit window without being hit are misses.
func _expire_missed_notes(now: float) -> void:
	while _first_live < _notes.size():
		var note: Dictionary = _notes[_first_live]
		if note["resolved"]:
			_first_live += 1
			continue
		if now - float(note["time"]) <= Judgement.HIT_WINDOW:
			break
		note["resolved"] = true
		_first_live += 1
		note_missed.emit(int(note["lane"]))


func _check_finished(now: float) -> void:
	if _finished or chart == null:
		return
	var spb := 60.0 / maxf(chart.bpm, 1.0)
	if now >= chart.total_beats() * spb and _first_live >= _notes.size():
		_finished = true
		chart_finished.emit()


func _unhandled_input(event: InputEvent) -> void:
	if conductor == null or not conductor.running:
		return
	if not (event is InputEventKey or event is InputEventJoypadButton):
		return
	for lane in LANE_ACTIONS.size():
		if event.is_action_pressed(LANE_ACTIONS[lane], false, true):
			_hit_lane(lane)
			get_viewport().set_input_as_handled()
			return


func _hit_lane(lane: int) -> void:
	_lane_flash[lane] = 1.0
	var now := conductor.song_position

	var best_index := -1
	var best_error := Judgement.HIT_WINDOW
	for i in range(_first_live, _notes.size()):
		var note: Dictionary = _notes[i]
		var error := float(note["time"]) - now
		# The list is time-ordered, so once we're past the window we're done.
		if error > Judgement.HIT_WINDOW:
			break
		if note["resolved"] or int(note["lane"]) != lane:
			continue
		if absf(error) > Judgement.HIT_WINDOW:
			continue
		if best_index == -1 or absf(error) < absf(best_error):
			best_index = i
			best_error = error

	if best_index == -1:
		# Pressing an empty lane isn't punished — it just does nothing. The
		# accuracy denominator is the chart, so stray taps can't inflate it.
		return

	_notes[best_index]["resolved"] = true
	var grade := Judgement.grade_for(best_error)
	note_judged.emit(grade, lane, best_error)


func _draw() -> void:
	var width := field_width()
	draw_rect(Rect2(-lane_gap, hit_line_y - scroll_distance, width + lane_gap * 2.0, scroll_distance + 80.0), Color(0.05, 0.04, 0.09, 0.85))

	for lane in RhythmChart.LANE_COUNT:
		var x := _lane_x(lane)
		var base: Color = LANE_COLORS[lane]

		# Lane body + receptor.
		draw_rect(Rect2(x, hit_line_y - scroll_distance, lane_width, scroll_distance), Color(base.r, base.g, base.b, 0.06))
		var flash: float = _lane_flash[lane]
		draw_rect(Rect2(x, hit_line_y - 4.0, lane_width, 8.0), base.lerp(Color.WHITE, flash))
		draw_rect(Rect2(x, hit_line_y + 8.0, lane_width, 40.0), Color(base.r, base.g, base.b, 0.15 + flash * 0.5))

	if conductor == null or not conductor.running:
		return

	var now := conductor.song_position
	for i in range(_first_live, _notes.size()):
		var note: Dictionary = _notes[i]
		var time_left := float(note["time"]) - now
		if time_left > approach_seconds:
			break
		if note["resolved"]:
			continue
		var progress := 1.0 - (time_left / approach_seconds)
		var y := hit_line_y - scroll_distance + progress * scroll_distance
		var lane := int(note["lane"])
		draw_rect(Rect2(_lane_x(lane) + 6.0, y - note_height * 0.5, lane_width - 12.0, note_height), LANE_COLORS[lane])
