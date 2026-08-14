extends Node2D

## Continuously waving line, left screen edge to the title art.

@export var start_x: float = 0.0
@export var end_x: float = 280.0
@export var wave_y: float = 210.0
@export var amplitude: float = 20.0
@export var wavelength: float = 260.0
@export var speed: float = 2.5
@export var line_width: float = 4.0
@export var color: Color = Color(0.65, 0.85, 1.0, 0.9)

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var points: PackedVector2Array = []
	var step := 4.0
	var x := start_x
	while x <= end_x:
		var y := wave_y + sin((x / wavelength) * TAU - _time * speed) * amplitude
		points.append(Vector2(x, y))
		x += step
	if points.size() > 1:
		draw_polyline(points, color, line_width, true)
