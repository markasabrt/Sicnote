# Sprites

Owned by the second developer (see "Asset Ownership" in
`docs/design/TECH_DECISIONS.md`). Nothing here yet — the vertical slice runs on
primitive meshes and code-drawn rectangles so systems work can proceed without
blocking on art.

Characters are billboarded 2D sprites in the final game, so drop-in points are:

- `scenes/world/player.tscn` → `Body/Mesh` (replace the capsule with a Sprite3D)
- `scenes/world/encounter.tscn` → `Mesh`
- `scripts/rhythm/note_field.gd` → `_draw()` (swap primitives for textures)
