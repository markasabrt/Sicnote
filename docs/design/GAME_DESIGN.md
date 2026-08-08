# Sicnote — Game Design Reference

> Transcribed and organized from the original design doc, `Sicnote.docx` (kept alongside this
> file for reference). This is the source of truth for narrative, world, and system intent
> until it's superseded by a revised doc or explicit direction from the designer.

- **Genre:** RPG, rhythm, fighting
- **Theme:** Autonomy over your own actions (primary); see also Emotional Autonomy below (secondary)
- **Target playtime:** ~10 hours (implied — see Emotional Autonomy and Origin of the Gifted sections, which are explicitly meant to help pad toward this)

## Production Approach

- **Characters** are billboarded 2D sprite art (always rotates to face the camera) rather than
  full 3D models — avoids rigging/animating a 3D model for every character in the cast.
- **Dialogue** is sizeable in volume, with real voice acting. Friends are voicing characters for
  free; quality bar stays high regardless.
- **Hand-drawn animation** is used sparingly — reserved for the biggest emotional story beats, so
  it stays special and stays achievable.
- **Exploration** happens in 3D. **Fighting** happens in 2D and plays like a rhythm game, with
  small, inconsequential minigames woven in along the way.

## World Concept: Notes

Every person in Sicnote is equivalent to a note in standard musical notation. Note *duration*
governs a character's nature:

| Note | Beats | Trait |
|---|---|---|
| Whole | 4 | Slow, effectively old and "kinda senile" |
| Half | 2 | |
| Quarter | 1 | |
| Eighth | 0.5 | |
| Sixteenth | 0.25 | |
| Thirty-second | 0.125 | |
| Sixty-fourth | 0.0625 | Fast |

Longer notes read as older; shorter notes read as faster — but characters in this universe don't
actually age. Duration is closer to a personality/archetype axis than a lifespan.

## The Gifted & Tyrannical Hypnosis

- **Gifted children** are notes granted unusual power and prowess at birth. They can influence
  other notes' decisions, which makes them the true (secret) power behind the world — society
  functions more like a puppet show for the gifted's whims than a free, functional society.
- Nobody knows the gifted have this ability — **not even the general population**, only the
  gifted themselves know.
- The power is called **tyrannical hypnosis**: invisible electric waves that interfere with a
  person's neurons, inserting information that shouldn't be there and steering their decisions.
- Tyrannical hypnosis behaves less like a power someone chooses to wield and more like an
  **infection** — anyone who has it *will* use it, involuntarily. This means the gifted aren't
  purely villains; they're trapped by what they were born into, same as everyone else is trapped
  by them.
- **Origin:** being gifted comes from *where* you're born. A handful of ancient spots scattered
  around the world look completely ordinary on the surface but secretly harbor power (possibly
  underground). Any note born on one of these spots is inscribed with tyrannical hypnosis at
  birth.
- **Ending the infection permanently** means destroying the ancient monuments/spots at the
  source — this stops any new gifted from being born and frees everyone currently under the
  effect, restoring autonomy for good.

## The Protagonist — Misa

- A **64th note** — fast by nature.
- Kind, shyish, misunderstood, left out (other notes struggle to "harmonize" with her), very
  independent, dislikes physical touch. Has red hair.
- **Inciting incident:** Misa overhears a gifted person ambushing/threatening her sister over the
  phone, not realizing Misa is listening. The gifted accidentally reveals the secret of their
  power. This discovery drives the entire plot — Misa wants revenge for her sister and to free
  the world.

## The Sigil

- Misa finds an ancient, top-secret book in her attic — one half of a two-book collection — that
  lays out the real, canonical history of the Sicnote world (as opposed to the false version
  taught in school history books), including the actual imperial wars and the effects of
  tyrannical hypnosis.
- It reveals that a **black sigil scribed on your back** can nullify the effects of tyrannical
  hypnosis — but it only activates correctly if it's drawn by someone you're close with.
- Misa finds a way to get the sigil scribed onto her back despite not having the full picture,
  driven purely by wanting revenge for her sister and to free the world.
- The **second book** (which Misa doesn't have) covers what the sigil does to the person wearing
  it: its black ink slowly spreads, granting heightened perception, acrobatics, and strength —
  this is the in-fiction explanation for the game's **leveling system**. It also explains that the
  sigil will eventually consume the wearer entirely, slowly crumbling their body away until death.

## Fighting

- **Vs. a hypnotized fast note** (32nd or 64th): a rhythm-game fight requiring **90% accuracy**
  to win. Lore justification: you beat a fast note by being faster than them — this tires them
  out and frees them from tyrannical hypnosis. Notes are generally averse to conflict and try to
  resolve things non-violently; the mind control is what forces the aggressive behavior. Freeing
  them makes them pass out (effectively "giving up"), though it doesn't prevent them from being
  hypnotized again later.
- **Vs. a note that isn't hypnotized:** a standard fighting-game encounter, not rhythm-based.
- **Example set-piece fight** (not yet placed in the plot): Misa fights an opponent who is
  fighting an emotional battle rather than being mind-controlled. The usual rhythm win condition
  (hitting the accuracy threshold that makes an opponent pass out) doesn't trigger. Misa doesn't
  understand why the opponent won't go down. The fight resolves when the opponent goes all-out
  attacking, forcing Misa to switch from attacking inputs to **blocking** — using the *same*
  rhythm-timing inputs, just repurposed, so it needs no separate tutorial. After enduring the
  attacks without retaliating for a few seconds, the opponent tires herself out crying and the
  fight ends. Would include a fully hand-drawn cutscene, and could double as the moment a new
  ally joins the group.

## Aesthetic

- Fight backgrounds should be elaborate and very colorful.
- Heavy inspiration from vintage retro game systems and old digital media/CRT-era style. See
  mood references in `references/`:
  - `gameboy-pocket-ad.jpg` — 1997 Game Boy Pocket print ad
  - `crt-glitch-mood.jpg` — glitchy CRT/VHS-style imagery
  - `90s-nostalgia-mood.jpg` — Crystal Pepsi / CD-era nostalgia collage

## Music

Each chapter has its own genre: rock, hip-hop, alt rock, breakcore, pop.

## Items

Equippable items are the player's outfit — each piece grants unique charms and abilities.

## Ending

The sigil slowly consuming Misa is what the ending is built around. As it consumes her, she
chooses to sacrifice herself for the betterment of the world rather than passively letting the
sigil take her — that active choice is the final expression of the autonomy theme.

## Emotional Autonomy (Secondary Theme)

Autonomy isn't only about being controlled from the outside — some people simply can't control
their own emotions either (e.g. someone who can't will away their own sadness or depression).
This doesn't run through the main plot; it lives in optional side content and side characters,
which also helps stretch playtime toward the ~10 hour mark without bloating the core story.

## Open Questions

The source doc flags these explicitly as undecided. Treat them as open — don't resolve or
flesh them out without direction:

- Whether Misa's death and the destruction of the ancient monuments happen as the same act, or
  as two separate events near the end.
- Whether/how Misa ever learns where the ancient power spots actually are (nobody in-world
  knows), and whether that's revealed to her later by someone or something.
