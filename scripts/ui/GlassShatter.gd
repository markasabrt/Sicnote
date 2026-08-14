extends Node2D
class_name GlassShatter
## Cracks `current_texture` into irregular glass-shard shapes (a jittered grid
## lattice, so neighboring shards stay flush and full-size until they move),
## flashes crack lines along the shard seams, holds a beat, then drops the
## shards straight off screen with a bit of spin, revealing `next_texture`
## underneath. Self-contained so any screen can reuse it as a "crack and fall
## away" transition; caller awaits play_shatter() then swaps scenes.

@export var current_texture: Texture2D
@export var next_texture: Texture2D
@export var canvas_size: Vector2 = Vector2(1920, 1080)
@export var columns: int = 10
@export var rows: int = 6
## How far interior lattice points can wander, as a fraction of a cell's size
## — this is what turns the grid into jagged, unequal shard shapes.
@export_range(0.0, 0.5) var jitter: float = 0.35
@export var crack_line_width: float = 2.5
@export var crack_line_color: Color = Color(0.05, 0.05, 0.08, 0.85)
## Beat between the crack lines appearing and the shards falling.
@export var hold_after_crack: float = 0.45
@export var base_fall_duration: float = 0.65
@export var max_rotation_degrees: float = 130.0
## Extra travel past the bottom edge so every shard is fully gone by the time
## it's cleaned up.
@export var fall_clear_padding: Vector2 = Vector2(160.0, 400.0)

const _REFERENCE_FALL_DISTANCE := 700.0

var _reveal: Sprite2D
var _crack_layer: Node2D
var _lattice: Array[PackedVector2Array] = []
var _shards: Array[Polygon2D] = []


func play_shatter() -> void:
	_spawn_reveal()
	_lattice = _build_lattice()
	_spawn_shards()
	_spawn_crack_lines() # the seams just appear — shards stay full size
	await get_tree().create_timer(hold_after_crack).timeout
	await _fall_shards()
	_cleanup()


func _spawn_reveal() -> void:
	_reveal = Sprite2D.new()
	_reveal.texture = next_texture
	_reveal.centered = true
	_reveal.position = canvas_size * 0.5
	add_child(_reveal)


## (rows + 1) x (columns + 1) grid of points; interior points are jittered,
## border points stay put so the whole lattice still tiles the screen exactly.
func _build_lattice() -> Array[PackedVector2Array]:
	var cell := Vector2(canvas_size.x / columns, canvas_size.y / rows)
	var lattice: Array[PackedVector2Array] = []
	for row in rows + 1:
		var line := PackedVector2Array()
		var on_h_border := row == 0 or row == rows
		for col in columns + 1:
			var point := Vector2(col * cell.x, row * cell.y)
			var on_border := on_h_border or col == 0 or col == columns
			if not on_border:
				point += Vector2(
					randf_range(-jitter, jitter) * cell.x,
					randf_range(-jitter, jitter) * cell.y
				)
			line.append(point)
		lattice.append(line)
	return lattice


func _spawn_shards() -> void:
	if current_texture == null:
		return
	for row in rows:
		for col in columns:
			var shard_points := PackedVector2Array([
				_lattice[row][col],
				_lattice[row][col + 1],
				_lattice[row + 1][col + 1],
				_lattice[row + 1][col],
			])
			_spawn_shard(shard_points)


func _spawn_shard(texture_points: PackedVector2Array) -> void:
	var centroid := Vector2.ZERO
	for point in texture_points:
		centroid += point
	centroid /= texture_points.size()

	var local_points := PackedVector2Array()
	for point in texture_points:
		local_points.append(point - centroid)

	var shard := Polygon2D.new()
	shard.texture = current_texture
	shard.polygon = local_points
	shard.uv = texture_points
	shard.position = centroid
	add_child(shard)
	_shards.append(shard)


## Draws the crack pattern along the interior lattice seams (not the outer
## canvas edges) on top of the still-whole shards.
func _spawn_crack_lines() -> void:
	_crack_layer = Node2D.new()
	add_child(_crack_layer)

	for row in range(1, rows):
		_add_crack_line(_lattice[row])

	for col in range(1, columns):
		var pts := PackedVector2Array()
		for row in rows + 1:
			pts.append(_lattice[row][col])
		_add_crack_line(pts)


func _add_crack_line(points: PackedVector2Array) -> void:
	var line := Line2D.new()
	line.points = points
	line.width = crack_line_width
	line.default_color = crack_line_color
	_crack_layer.add_child(line)


func _fall_shards() -> void:
	var longest := 0.0
	for shard in _shards:
		var delay := randf_range(0.0, 0.15)
		var fall_distance := (canvas_size.y - shard.position.y) \
			+ randf_range(fall_clear_padding.x, fall_clear_padding.y)
		var duration := base_fall_duration * sqrt(fall_distance / _REFERENCE_FALL_DISTANCE) \
			* randf_range(0.85, 1.15)
		var fall := Vector2(randf_range(-50.0, 50.0), fall_distance)
		var spin := deg_to_rad(randf_range(-max_rotation_degrees, max_rotation_degrees))

		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(shard, "position", shard.position + fall, duration) \
			.set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(shard, "rotation", spin, duration) \
			.set_delay(delay).set_trans(Tween.TRANS_LINEAR)

		longest = maxf(longest, delay + duration)

	if _crack_layer:
		_crack_layer.queue_free() # shards separating during the fall reads as the crack now
		_crack_layer = null

	await get_tree().create_timer(longest).timeout


func _cleanup() -> void:
	for shard in _shards:
		shard.queue_free()
	_shards.clear()
	if _reveal:
		_reveal.queue_free()
		_reveal = null
