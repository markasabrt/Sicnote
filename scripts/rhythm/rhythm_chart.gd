class_name RhythmChart
extends Resource
## A fight's note pattern. Two parallel arrays rather than an array of objects
## so charts stay cheap to author, diff, and hand to a tool later.
##
## If `note_beats` is empty at play time the chart generates itself from the
## procedural parameters below — that's what the vertical slice uses, since
## authored charts belong with real music.

const LANE_COUNT := 4

@export var bpm: float = 120.0
@export var lead_in_beats: float = 4.0
## Silence after the last note before the fight is scored.
@export var tail_beats: float = 2.0

## Beat position of each note, and which lane it falls in. Same length.
@export var note_beats: PackedFloat32Array = PackedFloat32Array()
@export var note_lanes: PackedInt32Array = PackedInt32Array()

@export_group("Procedural fallback")
## The opponent's note duration in beats — a 64th-note enemy (0.0625) throws
## dense bursts, a 32nd (0.125) a slower stream.
@export var enemy_note_beats: float = 0.125
@export var length_beats: float = 32.0
@export var seed_value: int = 20250808


func note_count() -> int:
	return mini(note_beats.size(), note_lanes.size())


func last_beat() -> float:
	if note_count() == 0:
		return 0.0
	return note_beats[note_count() - 1]


func total_beats() -> float:
	return last_beat() + tail_beats


## Fill in a placeholder pattern if none was authored. Idempotent.
func ensure_notes() -> void:
	if note_count() > 0:
		return
	generate(enemy_note_beats, length_beats, seed_value)


## Build a pattern whose density comes from the opponent's note value: the
## faster the note, the tighter the subdivision the player has to match.
func generate(opponent_beats: float, length: float, chart_seed: int) -> void:
	note_beats = PackedFloat32Array()
	note_lanes = PackedInt32Array()

	var rng := RandomNumberGenerator.new()
	rng.seed = chart_seed

	# A 64th note at 120 BPM is 32 hits/sec — unplayable as literal input, and
	# the fiction only asks that the player be faster than the opponent, not
	# that they match their note one-for-one. So the pattern is the opponent's
	# note value scaled to a human subdivision, and their *speed* shows up as
	# density and burst length instead.
	var step := clampf(opponent_beats * 4.0, 0.25, 1.0)
	var burst_length := clampi(int(round(0.5 / maxf(opponent_beats, 0.0156))), 2, 8)

	var beat := 0.0
	var lane := rng.randi_range(0, LANE_COUNT - 1)
	while beat < length:
		# Alternate bursts of notes with a breath, so it reads as phrases.
		var burst := rng.randi_range(2, burst_length)
		for i in burst:
			if beat >= length:
				break
			note_beats.append(beat)
			note_lanes.append(lane)
			# Step to an adjacent lane most of the time; jump occasionally.
			if rng.randf() < 0.25:
				lane = rng.randi_range(0, LANE_COUNT - 1)
			else:
				lane = clampi(lane + (1 if rng.randf() < 0.5 else -1), 0, LANE_COUNT - 1)
			beat += step
		beat += step * rng.randi_range(1, 2)


static func for_enemy(opponent_beats: float, length: float = 32.0, chart_seed: int = 20250808) -> RhythmChart:
	var chart := RhythmChart.new()
	chart.enemy_note_beats = opponent_beats
	chart.length_beats = length
	chart.seed_value = chart_seed
	chart.generate(opponent_beats, length, chart_seed)
	return chart
