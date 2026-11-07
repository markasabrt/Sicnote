class_name PlayerExplorer
extends CharacterBody3D
@export var jump_g_multiplier: float = 1.7
@export var jump_decay: float = .55
@export var jump_velocity: float = 10 
@export var active_rate: float = 0
@export var target_speed: float = 0
@export var sprint_timer: float = 0
@export var current_speed: float = 0
@export var move_speed: float = 5.5
@export var run_speed: float = 8.5
@export var sprint_speed: float = 11.5
@export var acceleration: float = 15.0
@export var deceleration: float = 17
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
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		_gravity *= jump_g_multiplier
		jump_velocity == sqrt(jump_g_multiplier) 
		velocity.y = jump_velocity
	elif velocity.y == 0: 
		_gravity = 9.8  
	if Input.is_action_just_released("jump") and velocity.y > 0:
		velocity.y *= jump_decay
		
	
		
	if Input.is_action_pressed("Run"):
		target_speed = run_speed
		sprint_timer += delta
		if sprint_timer >= 3:
			target_speed = sprint_speed
		

	else :
		sprint_timer = 0
		target_speed = move_speed
	if target_speed > current_speed:
		active_rate = acceleration   # Speeding up 
	else:
		active_rate = deceleration   # Slowing down
	current_speed = move_toward(current_speed, target_speed, active_rate * delta)
	
	
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# Movement is relative to where the camera is looking, not to world axes.
	var basis_yaw := Basis(Vector3.UP, _pivot.rotation.y)
	var direction := (basis_yaw * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	if direction != Vector3.ZERO:
	# While pressing movement keys, move at current_speed using acceleration
		velocity.x = move_toward(velocity.x, direction.x * current_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * current_speed, acceleration * delta)
	else:
	# When keys are released, slide velocity down to 0 using deceleration
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, deceleration * delta)

	move_and_slide()

	if direction.length_squared() > 0.01:
		var facing := atan2(-direction.x, -direction.z)
		_body_mesh.rotation.y = lerp_angle(_body_mesh.rotation.y, facing, 12.0 * delta)
