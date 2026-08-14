class_name BlipPlayer
extends Node
## Small pool of AudioStreamPlayers so overlapping blips don't cut each other
## off. Add one wherever short synthesized cues are needed (dialogue box,
## fight scene); it needs no configuration.

const POOL_SIZE := 8

var _players: Array[AudioStreamPlayer] = []
var _next := 0


func _ready() -> void:
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_players.append(player)


func play_voice(voice: NoteVoice, pitch_scale: float = 1.0) -> void:
	if voice == null:
		return
	play_stream(voice.blip_stream(), pitch_scale)


func play_stream(stream: AudioStream, pitch_scale: float = 1.0) -> void:
	if stream == null or _players.is_empty():
		return
	var player := _players[_next]
	_next = (_next + 1) % _players.size()
	player.stream = stream
	player.pitch_scale = pitch_scale
	player.play()


func stop_all() -> void:
	for player in _players:
		player.stop()
