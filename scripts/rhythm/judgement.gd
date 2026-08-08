class_name Judgement
extends RefCounted
## Timing windows and accuracy scoring for rhythm fights.
##
## Accuracy is what the whole fight hangs on: beating a hypnotized fast note
## requires 90% (GAME_DESIGN.md, "Fighting"), and accuracy — not grinding — is
## also what earns ink (TECH_DECISIONS.md, "Leveling system").

enum Grade { PERFECT, GREAT, GOOD, MISS }

## Absolute timing error, in seconds, that still counts as each grade.
const PERFECT_WINDOW := 0.045
const GREAT_WINDOW := 0.090
const GOOD_WINDOW := 0.140
## Beyond this a note can no longer be hit at all and is scored as a miss.
const HIT_WINDOW := 0.170

## Win threshold for a hypnotized fast note.
const WIN_ACCURACY := 0.90

const _WEIGHTS := {
	Grade.PERFECT: 1.0,
	Grade.GREAT: 0.75,
	Grade.GOOD: 0.40,
	Grade.MISS: 0.0,
}

const _NAMES := {
	Grade.PERFECT: "PERFECT",
	Grade.GREAT: "GREAT",
	Grade.GOOD: "GOOD",
	Grade.MISS: "MISS",
}


static func grade_for(delta_seconds: float) -> int:
	var error := absf(delta_seconds)
	if error <= PERFECT_WINDOW:
		return Grade.PERFECT
	if error <= GREAT_WINDOW:
		return Grade.GREAT
	if error <= GOOD_WINDOW:
		return Grade.GOOD
	return Grade.MISS


## Takes a plain int so signals can carry grades without enum-cast friction.
static func weight(grade: int) -> float:
	return _WEIGHTS.get(grade, 0.0)


static func grade_name(grade: int) -> String:
	return _NAMES.get(grade, "MISS")


## Accuracy over a whole chart. `total_notes` is the chart length, so notes
## that scrolled past unhit correctly drag the score down.
static func accuracy(earned_weight: float, total_notes: int) -> float:
	if total_notes <= 0:
		return 0.0
	return clampf(earned_weight / float(total_notes), 0.0, 1.0)


## Ink awarded for a fight. Performance-based, never grind-based.
static func ink_reward(acc: float, won: bool) -> int:
	var base := int(round(acc * 120.0))
	return base + (40 if won else 0)
