extends Node3D

const NORMAL_FOV : float = 75.0
const RUN_FOV : float = 90.0
const CAMERA_BLEND : float = 0.05

@onready var spring_arm : SpringArm3D = $SpringArm3D
@onready var camera : Camera3D = $SpringArm3D/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		spring_arm.rotate_x(-event.relative.y * 0.005)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)

func _physics_process(_delta):
	if owner.is_on_floor():
		if Input.is_action_pressed("run"):
			camera.fov = lerp(camera.fov, RUN_FOV, CAMERA_BLEND)
		else:
			camera.fov = lerp(camera.fov, NORMAL_FOV, CAMERA_BLEND)
	else:
		camera.fov = lerp(camera.fov, NORMAL_FOV, CAMERA_BLEND)
