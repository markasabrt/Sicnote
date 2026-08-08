# Sicnote

Sicnote is a narrative RPG/rhythm/fighting hybrid. **Engine: Godot 4.7, GDScript, PC only** (see
`docs/design/TECH_DECISIONS.md`). The first vertical slice is built and playable end to end:
splash → 3D rotating-cube main menu → 3D exploration → encounter → pre-fight note-blip dialogue →
2D rhythm fight → post-fight dialogue → back to exploration, with ink awarded on a win.
Everything visual is placeholder (primitive meshes, code-drawn notes) and all audio is
synthesized in code.

## Orientation

- Full design reference: `docs/design/GAME_DESIGN.md` — transcribed and organized from the
  original design doc (`docs/design/Sicnote.docx`, kept alongside it as the primary source).
- Tech/implementation decisions: `docs/design/TECH_DECISIONS.md` — engine, language, scene
  architecture, and system-level choices, kept separate from narrative design. Distinguishes
  **Decided** from **Proposed** — treat Proposed items as recommendations pending confirmation.
- Mood/aesthetic reference images: `docs/design/references/`.

Code layout (classic type-based, per `TECH_DECISIONS.md`):

- `autoloads/` — `GameState` (full persisted state: ink, level, traits, flags, inventory, world
  state) and `SceneManager` (every scene transition and the payload handed between scenes; no
  scene calls `change_scene_to_file` itself).
- `scripts/rhythm/` — the in-house rhythm engine: `Conductor` (audio-clock timing),
  `RhythmChart` (patterns, with procedural fallback), `Judgement` (windows, accuracy, ink),
  `NoteField` (falling notes and input).
- `scripts/audio/` — `NoteVoice` synthesizes a character's blip from their note value;
  `BlipPlayer` is the voice pool. No audio assets involved.
- `scripts/dialogue/` — `DialogueBox` (typewriter keyed to the speaker's note) and `Speakers`
  (the id → note registry; adding a character is one line).
- `scenes/` mirrors the same split; `scripts/world/` and `scripts/ui/` hold exploration and
  menu/splash code.

Read `docs/design/GAME_DESIGN.md` and `docs/design/TECH_DECISIONS.md` before doing any
narrative, systems, or code work — together they're the source of truth for the game's world,
characters, mechanics, and implementation approach as currently conceived.

## Working on this project

- **Tech stack is settled**: Godot 4 (latest stable) / GDScript / PC-only / Forward+, classic
  type-based folder structure, keyboard-and-mouse-first input (controller support possible
  later, not built now), 3D exploration with a hard scene transition into dedicated 2D fight
  scenes, in-house rhythm engine, custom dialogue system with procedural note-blip audio,
  full-state save system, and a sigil/leveling system where the same "ink" value drives both
  progression and the ending's consumption arc.
- **The first vertical slice is built** — see "First vertical slice scope" in
  `TECH_DECISIONS.md` for what it covers and its success criterion (Misa's 64th-note blip should
  be audibly, distinctly fast). Blip rate and pitch both come from one value, the character's
  note duration, so judging that criterion means listening to `NoteVoice`, not tweaking a text
  speed somewhere.
- **Sprite art and audio/music are owned by a second developer**, not by whoever is working in
  this repo on systems/code. Build and test gameplay systems (rhythm engine, dialogue, leveling
  UI) against placeholder assets, keep asset-facing code swappable, and don't make final art or
  audio pipeline decisions here — see "Asset Ownership" in `TECH_DECISIONS.md`.
- **The design doc has open questions**, called out explicitly in a dedicated section at the
  bottom of `GAME_DESIGN.md`. Don't invent resolutions to those on your own initiative; ask the
  designer, or leave them flagged as open. The rest of the doc is fair to reference and build on
  directly.
- If the designer shares an updated version of `Sicnote.docx` or describes design changes in
  conversation, update `docs/design/GAME_DESIGN.md` (and the copy of the `.docx` if a new file
  is provided) to keep this the current reference rather than letting it drift out of date.
