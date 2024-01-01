extends CharacterBody3D

const LERP_VALUE : float = 0.15

var snap_vector : Vector3 = Vector3.DOWN
var speed : float
var joyright_rotation : float
var touch_running : bool = false

@export_group("Movement variables")
@export var walk_speed : float = 2.0
@export var run_speed : float = 5.0
@export var jump_strength : float = 15.0
@export var gravity : float = 50.0
@export var rotation_sensitivity : float = 0.03

@export_group("Virtual Joysticks")
@export var joystick_left : VirtualJoystick
@export var joystick_right : VirtualJoystick

const ANIMATION_BLEND : float = 7.0

@onready var player_mesh : Node3D = $Mesh
@onready var spring_arm_pivot : Node3D = $SpringArmPivot
@onready var animator : AnimationTree = $AnimationTree
@onready var spring_arm : SpringArm3D = $SpringArmPivot/SpringArm3D

func _ready():
	OS.low_processor_usage_mode = OS.get_name() != "Android"
	
func _physics_process(delta):
	var move_direction : Vector3 = Vector3.ZERO
	move_direction.x = Input.get_axis("ui_left", "ui_right") # Input.get_action_strength("move_right") - Input.get_action_strength("move_left") # 
	move_direction.z = Input.get_axis("ui_up", "ui_down") # Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	
	velocity.y -= gravity * delta
	
	if joystick_right and joystick_right.is_pressed:

		var rotation_speed = joystick_right.output.x * rotation_sensitivity
		spring_arm_pivot.rotate_y(-rotation_speed)

		var vertical_rotation_speed = joystick_right.output.y * rotation_sensitivity
		spring_arm.rotate_x(-vertical_rotation_speed)
	
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)
		
	if Input.is_action_pressed("run") or (touch_running == true):
		speed = run_speed
	else:
		speed = walk_speed
		
	if Input.is_action_pressed("ui_cancel"):  # Change "ui_cancel" to your defined "esc" action if different
		get_tree().quit()

	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	
	if move_direction:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
	
	var just_landed := is_on_floor() and snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	if is_jumping:
		velocity.y = jump_strength
		snap_vector = Vector3.ZERO
	elif just_landed:
		snap_vector = Vector3.DOWN
	
	apply_floor_snap()
	move_and_slide()
	animate(delta)

func animate(delta):
	if is_on_floor():
		animator.set("parameters/ground_air_transition/transition_request", "grounded")
		
		if velocity.length() > 0:
			if speed == run_speed:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))
			else:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
		else:
			animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
	else:
		animator.set("parameters/ground_air_transition/transition_request", "air")


func _on_button_sprint_touch_pressed():
	touch_running = true

func _on_button_sprint_touch_released():
	touch_running = false
