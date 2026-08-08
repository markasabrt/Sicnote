# Sicnote — Technical Decisions

Implementation-level choices, separate from `GAME_DESIGN.md` (which stays narrative/world
focused). Entries are either **Decided** or **Proposed** — proposed items are recommendations,
not commitments, and shouldn't be treated as final until confirmed.

## Decided

- **Platform:** PC only.
- **Engine:** Godot 4, latest stable release. Update policy: track latest stable rather than
  pinning to an older LTS-style version.
- **Language:** GDScript.
- **Project folder structure:** classic, type-based Godot layout — flat and conventional, not a
  deep feature-sharded or over-engineered "everything gets its own module" hierarchy. Default
  shape: `scenes/`, `scripts/`, `assets/` (with `sprites/`, `audio/`, `fonts/` inside),
  `resources/`, `autoloads/` — adjust as the project grows, but keep it a structure someone can
  navigate by looking at it, not one that needs a map.
- **Scene architecture:** Exploration happens in a 3D scene. Encountering an enemy transitions
  into a separate, dedicated 2D scene for the fight itself. Some sprites/characters may still be
  rendered as 3D objects even within the 2D fight scenes — "2D fighting" describes the gameplay
  being locked to a flat plane, not that every visual asset is a flat sprite.
- **Rhythm engine:** Built in-house (no third-party rhythm-game plugin/asset).
- **Dialogue delivery (interim):** Before real voice acting is recorded, dialogue uses an
  Undertale-style system where each character continuously "speaks" by playing their musical
  note while text scrolls, rather than silent text or generic blips. The blip should be the
  character's actual note (per the duration table in `GAME_DESIGN.md`) — e.g. a whole note
  blips slow and low, a 64th note blips in a fast, high chatter — so the sound reinforces their
  note identity even before VO exists.
  - **Blip audio generation:** procedural — synthesized in code from each character's note
    pitch/duration, as a first primitive solution, rather than authored/recorded per character.
	This is a systems decision even though audio is otherwise the other developer's domain,
	since it's generated rather than an asset.
  - **Long-term scope:** once real voice acting (friends recording lines) exists, VO replaces
	the procedural blip for general dialogue. The procedural note-blip system doesn't get
	thrown away — it narrows to fights and similar non-dialogue contexts where a literal voice
	line doesn't fit as well.
- **Dialogue system:** Custom-built rather than the Dialogic addon. Reasoning: the note-blip
  requirement is bespoke to Sicnote and needs custom code regardless of what runs the dialogue
  box, and Dialogic's main advantage (a visual branching-timeline editor) only pays off once
  dialogue trees/choices get complex, which isn't a confirmed need yet. Not mutually exclusive
  with adopting Dialogic later for branching if that need materializes — the note-blip component
  can plug into either.
- **Leveling system:** Tied to the sigil rather than a generic XP curve — the ink/consumption
  condition described below *is* the XP curve, not a system separate from it.
  - Rhythm-fight *performance* (accuracy/style rating), not grinding, earns "ink."
  - Ink is spent across the three traits the in-fiction second book already describes:
    perception, acrobatics, strength — matching what the sigil is said to grant as it spreads.
  - Visualize progression diegetically: the sigil's ink visibly spreads further across Misa's
    back on a status/level-up screen, rather than (or alongside) plain numbers.
  - The same ink total that powers leveling also drives consumption — there's no separate
	hidden meter. Leveling up *is* progressing toward the ending already planned in
	`GAME_DESIGN.md`: the more powerful she gets, the closer she is to the sigil consuming her.
  - **Reveal pacing:** the sigil's visible spread is tied to *level*, not raw ink — ink itself
    accumulates continuously in the background as a percentage toward the next level, but that
	percentage isn't surfaced to the player as a live-ticking meter. The player only learns
	their level (and sees the sigil grow) at the moment of level-up, not while it's happening.
    Intent: growth should read as discovered/surprising ("wait, it spread *that* much?") rather
    than something the player watches creep up in real time.
- **Save system:** saves the full state, not a slice of it — ink total, current level,
  unlocked/leveled abilities, story/quest completion flags, inventory/items, and world state.
- **Rendering pipeline:** Forward+. Fits PC-only and the "insane, very colorful" fight
  background goal better than the Mobile renderer's tradeoffs.
- **Input/control scheme:** keyboard and mouse are the primary, designed-for input for now.
  Controller support is a future possibility, not built or architected against yet — worth
  keeping input handling reasonably abstracted (e.g. action names via Godot's Input Map rather
  than hardcoded key checks) so adding it later doesn't mean reworking every input site, but no
  need to actively build or test for it now.
- **First vertical slice scope:** a single, complete gameplay loop, built fully working (not
  just prototyped), to prove out the riskiest unproven systems together before building any more
  content on top of them:
  1. **Splash screen.**
  2. **Main menu** — a 3D object, rotated by mouse manipulation, rather than a flat UI screen.
  3. Walk a small 3D exploration area.
  4. Encounter one hypnotized fast-note enemy.
  5. Transition into the 2D rhythm fight scene.
  6. Win the fight (90% accuracy threshold, per `GAME_DESIGN.md`).
  7. A short post-fight dialogue exchange using the note-blip system.
  - **Explicit success criterion:** the player should be able to actually *hear* Misa's note
	during this build — she's a 64th note (per `GAME_DESIGN.md`), so her procedural blip should
	read as fast, high-chatter audio, distinct from a slower note's blip. If the blip doesn't
	read as "64th note" on its own, that's a signal the procedural generation needs tuning
	before it's trusted for other characters.
  - Nothing beyond this loop needs to exist yet — no full map, no other characters, no leveling
	payoff, no menus beyond splash/main menu.
  - Some assets for this slice already exist (provided by the other developer/designer) rather
	than needing full placeholders — use what's available; fall back to placeholders per "Asset
    Ownership" below only where something is still missing.

## Asset Ownership

Sprite art and audio/music are handled by a second developer, not by whoever is writing systems
code. This doesn't remove those systems from scope — the rhythm engine, dialogue box, and
leveling/status UI all need *something* to render/play — it just means:

- Build and test systems against placeholder assets (programmer-art sprites, placeholder/synth
  audio) rather than blocking on final art or recorded audio.
- Keep asset-facing code swappable (e.g. don't hardcode a specific sprite sheet's layout into
  fight logic) so real assets can drop in later without a systems rewrite.
- Final art/audio tooling and pipeline choices belong to the other developer, not to this repo's
  systems-side tech decisions.

## Open Tech Questions

All prior open items are now decided (see above). None currently outstanding — add new ones here
as they come up.
