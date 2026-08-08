class_name Conductor
extends Node
## The clock everything in a rhythm fight reads from.
##
## When a music track is playing, time comes from the audio playback position
## (corrected for mix + output latency) rather than from frame delta — frame
## time drifts against audio and drift is exactly what a rhythm game can't
## tolerate. With no track assigned it falls back to a monotonic clock, which
## is what the vertical slice uses until the other developer's music lands.

signal beat_hit(beat_index: int)
signal started()
signal finished()

@export var bpm: float = 120.0
## Silence before the first beat, so the player can find the tempo.
@export var lead_in_beats: float = 4.0
## Optional music track. Leave null for the placeholder (metronome-only) fight.
@export var music: AudioStream

var running := false
## Seconds since the chart's beat 0. Negative during the lead-in.
var song_position := 0.0
var song_position_beats := 0.0

var _player: AudioStreamPlayer
var _start_usec: int = 0
var _last_reported_beat := -1
var _latency := 0.0


func seconds_per_beat() -> float:
	return 60.0 / maxf(bpm, 1.0)


func beats_to_seconds(beats: float) -> float:
	return beats * seconds_per_beat()


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	add_child(_player)
	set_process(false)


func start() -> void:
	_latency = AudioServer.get_output_latency()
	_last_reported_beat = int(floor(-lead_in_beats)) - 1
	song_position = -beats_to_seconds(lead_in_beats)
	song_position_beats = -lead_in_beats
	_start_usec = Time.get_ticks_usec()
	running = true
	set_process(true)

	if music != null:
		_player.stream = music
		# The track itself starts when the lead-in ends.
		_player.play()
		_player.stream_paused = true
	started.emit()


func stop() -> void:
	running = false
	set_process(false)
	if _player.playing:
		_player.stop()


func finish() -> void:
	if not running:
		return
	stop()
	finished.emit()


func _process(_delta: float) -> void:
	if not running:
		return
	song_position = _read_clock()
	song_position_beats = song_position / seconds_per_beat()

	var current_beat := int(floor(song_position_beats))
	while _last_reported_beat < current_beat:
		_last_reported_beat += 1
		beat_hit.emit(_last_reported_beat)


func _read_clock() -> float:
	var elapsed := float(Time.get_ticks_usec() - _start_usec) / 1_000_000.0
	var fallback := elapsed - beats_to_seconds(lead_in_beats)

	if music == null:
		return fallback

	# Release the paused track exactly when beat 0 arrives.
	if _player.stream_paused and fallback >= 0.0:
		_player.stream_paused = false
	if _player.stream_paused or not _player.playing:
		return fallback

	return _player.get_playback_position() + AudioServer.get_time_since_last_mix() - _latency
