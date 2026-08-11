class_name Speakers
extends RefCounted
## Who's who, and what note they are.
##
## A character's note duration decides their voice entirely (see NoteVoice), so
## this registry is deliberately tiny: an id, a display name, and a note value.
## Adding a character is one line.

const WHOLE := 4.0
const HALF := 2.0
const QUARTER := 1.0
const EIGHTH := 0.5
const SIXTEENTH := 0.25
const THIRTY_SECOND := 0.125
const SIXTY_FOURTH := 0.0625

## id -> { name, beats, semitone offset, waveform }
const REGISTRY := {
	"misa": {"name": "Misa", "beats": SIXTY_FOURTH, "offset": 0.0, "wave": NoteVoice.Wave.SQUARE},
	"runner": {"name": "Hypnotized Note", "beats": THIRTY_SECOND, "offset": -1.0, "wave": NoteVoice.Wave.SQUARE},
	"narrator": {"name": "", "beats": HALF, "offset": 0.0, "wave": NoteVoice.Wave.TRIANGLE},
}

static var _voice_cache: Dictionary = {}


static func display_name(id: String) -> String:
	return str(REGISTRY.get(id, {}).get("name", id))


static func voice_for(id: String) -> NoteVoice:
	if _voice_cache.has(id):
		return _voice_cache[id]

	var entry: Dictionary = REGISTRY.get(id, {})
	var voice := NoteVoice.from_beats(
		float(entry.get("beats", QUARTER)),
		float(entry.get("offset", 0.0)),
		int(entry.get("wave", NoteVoice.Wave.SQUARE))
	)
	_voice_cache[id] = voice
	return voice


## Ad-hoc voice for a character not in the registry (e.g. a generated enemy).
static func voice_from_beats(beats: float) -> NoteVoice:
	return NoteVoice.from_beats(beats)
