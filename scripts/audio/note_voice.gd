class_name NoteVoice
extends Resource
## A character's "voice" in Sicnote — derived entirely from which note they are.
##
## Every person in this world is a note (GAME_DESIGN.md, "World Concept: Notes"),
## and dialogue blips are that literal note rather than a generic chirp: a whole
## note blips slow and low, a 64th note blips as fast, high chatter.
##
## The waveform is synthesised in code (TECH_DECISIONS.md, "Blip audio
## generation") so no audio asset is needed — audio assets are the other
## developer's domain, and this stays swappable when real VO lands.

const MIX_RATE := 44100

## Reference tempo used to turn note *durations* into wall-clock seconds.
## The blip rate is musical, not arbitrary — at 120 BPM a beat is 0.5 s.
const REFERENCE_BPM := 120.0

## Blip period is clamped so a whole note is still readable and a 64th note is
## still audible as discrete blips rather than a solid tone.
const MIN_BLIP_PERIOD := 0.025  # 40 blips/sec
const MAX_BLIP_PERIOD := 0.25   #  4 blips/sec

## Pitch of a whole note (F3). Each halving of the note duration steps the
## pitch up by PITCH_STEP_SEMITONES, so shorter == higher.
const WHOLE_NOTE_HZ := 174.61
const PITCH_STEP_SEMITONES := 4.0

enum Wave { SQUARE, TRIANGLE, SINE }

## Note duration in beats: 4.0 = whole ... 0.0625 = 64th.
@export var note_beats: float = 1.0
## Per-character tuning so two characters on the same note aren't identical.
@export var pitch_offset_semitones: float = 0.0
## One of the Wave constants. Plain int so registries can hand one over
## without an enum cast.
@export var wave: int = Wave.SQUARE
@export_range(0.0, 1.0) var volume: float = 0.5

var _cached_stream: AudioStreamWAV
var _cached_signature: String = ""


static func from_beats(beats: float, offset_semitones: float = 0.0, wave_shape: int = Wave.SQUARE) -> NoteVoice:
	var voice := NoteVoice.new()
	voice.note_beats = beats
	voice.pitch_offset_semitones = offset_semitones
	voice.wave = wave_shape
	return voice


## Duration of one of this character's notes, in seconds, at REFERENCE_BPM.
func note_seconds() -> float:
	return note_beats * (60.0 / REFERENCE_BPM)


## How often a blip fires while this character speaks — i.e. how fast their
## text scrolls. This is the value that should make Misa read as "fast".
func blip_period() -> float:
	return clampf(note_seconds(), MIN_BLIP_PERIOD, MAX_BLIP_PERIOD)


func frequency() -> float:
	# Number of halvings between a whole note and this one: 64th -> 6.
	var steps := log(4.0 / maxf(note_beats, 0.001)) / log(2.0)
	var semitones := steps * PITCH_STEP_SEMITONES + pitch_offset_semitones
	return WHOLE_NOTE_HZ * pow(2.0, semitones / 12.0)


## Blips are short and percussive; a slow note gets a longer, fatter blip.
func blip_seconds() -> float:
	return clampf(blip_period() * 0.8, 0.018, 0.12)


func blip_stream() -> AudioStreamWAV:
	var signature := "%f|%f|%d|%f" % [note_beats, pitch_offset_semitones, wave, volume]
	if _cached_stream != null and signature == _cached_signature:
		return _cached_stream
	_cached_stream = synthesize(frequency(), blip_seconds(), wave, volume)
	_cached_signature = signature
	return _cached_stream


## Render a single blip to 16-bit mono PCM. Kept static so the fight scene can
## synthesize one-off cues (hit / miss / metronome) without inventing a voice.
static func synthesize(freq: float, duration: float, wave_shape: int = Wave.SQUARE, amplitude: float = 0.5) -> AudioStreamWAV:
	var frames := maxi(int(duration * MIX_RATE), 1)
	var attack_frames := maxi(int(0.002 * MIX_RATE), 1)  # 2 ms, kills the click
	var data := PackedByteArray()
	data.resize(frames * 2)

	var phase := 0.0
	var phase_step := freq / float(MIX_RATE)
	for i in frames:
		var t := float(i) / float(frames)
		# Fast percussive decay, plus a short attack ramp.
		var env := pow(1.0 - t, 2.2)
		if i < attack_frames:
			env *= float(i) / float(attack_frames)

		var sample := 0.0
		match wave_shape:
			Wave.SQUARE:
				sample = 1.0 if phase < 0.5 else -1.0
			Wave.TRIANGLE:
				sample = 4.0 * absf(phase - 0.5) - 1.0
			_:
				sample = sin(phase * TAU)

		var value := int(clampf(sample * env * amplitude, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, value)

		phase += phase_step
		if phase >= 1.0:
			phase -= 1.0

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	stream.data = data
	return stream
