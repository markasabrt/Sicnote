# Audio

Music and recorded audio are owned by the second developer (see "Asset
Ownership" in `docs/design/TECH_DECISIONS.md`).

The one exception, by decision rather than by accident: **note blips are
synthesized in code**, not authored here — see `scripts/audio/note_voice.gd`.
They're generated from each character's note value, so they're a systems
concern.

Drop-in points for real audio:

- Fight music → `Conductor.music` on `scenes/fight/fight_scene.tscn`. The
  conductor switches from its fallback clock to the audio playback clock
  automatically once a stream is assigned.
- Voice acting → replaces the blip in `scripts/dialogue/dialogue_box.gd` for
  general dialogue; the blip system stays for fights.
