extends Node3D
class_name CameraComponent

var camroot_h = 0
var camroot_v = 0

@export var cam_v_max = 75
@export var cam_v_min = -55
@export var h_sensitivity: float = 0.01
@export var v_sensitivity: float = 0.01
@export var h_acceleration: float = 10.0
@export var v_acceleration: float = 10.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camroot_h += -event.relative.x * h_sensitivity
		camroot_v += event.relative.y * v_sensitivity

func _physics_process(delta: float) -> void:
	camroot_v = clamp(camroot_v, deg_to_rad(cam_v_min), deg_to_rad(cam_v_max))
	get_node("CamHeight").rotation.y = lerpf(get_node("CamHeight").rotation.y, camroot_h, delta * h_acceleration)
	get_node("CamHeight/SpringArm3D").rotation.x = lerpf(get_node("CamHeight/SpringArm3D").rotation.x, camroot_v, delta * v_acceleration)
