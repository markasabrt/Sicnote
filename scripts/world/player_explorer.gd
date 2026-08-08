class_name PlayerExplorer
extends CharacterBody3D
## Third-person exploration controller for the 3D scenes.
##
## Keyboard and mouse are the designed-for input (TECH_DECISIONS.md), and every
## binding goes through the Input Map rather than raw keycodes so controller
## support later isn't a rewrite.
##
## The capsule mesh is a placeholder — the real Misa is a billboarded 2D sprite
## (GAME_DESIGN.md, "Production Approach"), which drops in as a sibling node
## without touching this script.

@export var move_speed: float = 5.5
@export var acceleration: float = 12.0
@export var mouse_sensitivity: float = 0.0032
@export var min_pitch_deg: float = -40.0
@export var max_pitch_deg: float = 25.0

@onready var _pivot: Node3D = $CamPivot
@onready var _body_mesh: Node3D = $Body

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)


func _ready() -> void:
	add_to_group("player")
	capture_mouse(true)


func capture_mouse(captured: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_mouse_capture"):
		capture_mouse(Input.mouse_mode != Input.MOUSE_MODE_CAPTURED)
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		_pivot.rotation.y -= motion.relative.x * mouse_sensitivity
		_pivot.rotation.x = clampf(
			_pivot.rotation.x - motion.relative.y * mouse_sensitivity,
			deg_to_rad(min_pitch_deg),
			deg_to_rad(max_pitch_deg)
		)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		velocity.y = 0.0

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# Movement is relative to where the camera is looking, not to world axes.
	var basis_yaw := Basis(Vector3.UP, _pivot.rotation.y)
	var direction := (basis_yaw * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	var target := direction * move_speed
	velocity.x = move_toward(velocity.x, target.x, acceleration * delta * move_speed)
	velocity.z = move_toward(velocity.z, target.z, acceleration * delta * move_speed)

	move_and_slide()

	if direction.length_squared() > 0.01:
		var facing := atan2(-direction.x, -direction.z)
		_body_mesh.rotation.y = lerp_angle(_body_mesh.rotation.y, facing, 12.0 * delta)
