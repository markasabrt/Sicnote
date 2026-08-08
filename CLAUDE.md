# Sicnote

Sicnote is a narrative RPG/rhythm/fighting hybrid, currently in **pre-production**. This
repository has no source code yet — it currently holds design and tech-decision documentation
only. **Engine: Godot 4, GDScript, PC only** (see `docs/design/TECH_DECISIONS.md`).

## Orientation

- Full design reference: `docs/design/GAME_DESIGN.md` — transcribed and organized from the
  original design doc (`docs/design/Sicnote.docx`, kept alongside it as the primary source).
- Tech/implementation decisions: `docs/design/TECH_DECISIONS.md` — engine, language, scene
  architecture, and system-level choices, kept separate from narrative design. Distinguishes
  **Decided** from **Proposed** — treat Proposed items as recommendations pending confirmation.
- Mood/aesthetic reference images: `docs/design/references/`.

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
- **First vertical slice is scoped and confirmed** — see "First vertical slice scope" in
  `TECH_DECISIONS.md` for the exact loop (splash screen → rotating-3D-object main menu →
  explore → encounter → 2D rhythm fight → post-fight note-blip dialogue) and its success
  criterion (Misa's 64th-note blip should be audibly, distinctly fast). This is the actual next
  thing to build.
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
