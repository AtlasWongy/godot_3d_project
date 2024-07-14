extends CharacterBody3D


@onready var animation_tree = get_node("AnimationTree")
@onready var playback = animation_tree.get("parameters/playback")
@onready var cam_rotation_h = get_node("CamRoot/CamHeight")

@export var gravity: float = 9.8
@export var jump_force: int = 9
@export var walk_speed: int = 3
@export var run_speed: int = 10

var idle_node_name: String = "Idle"
var walk_node_name: String = "Walk"
var run_node_name: String = "Run"
var jump_node_name: String = "Jump"
var attack_node_name: String = "Attack"
var death_node_name: String = "Death"

var is_attacking: bool
var is_walking: bool
var is_running: bool
var is_dying: bool

var direction: Vector3
var horizontal_velocity: Vector3
var aim_turn: float
var movement: Vector3
var vertical_velocity: Vector3
var movement_speed: int
var angular_acceleration: int
var acceleration: int
var just_hit: bool = false

func _ready() -> void:
	direction = Vector3.BACK.rotated(Vector3.UP, cam_rotation_h.global_transform.basis.get_euler().y)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		aim_turn = -event.relative.x * 0.015
	if event.is_action_pressed("aim"):
		direction = cam_rotation_h.global_transform.basis.z
	
func _physics_process(delta: float) -> void:
	if !is_dying:
		if !is_on_floor():
			vertical_velocity += Vector3.DOWN * gravity * 2 * delta
		else:
			vertical_velocity = Vector3.DOWN * gravity /10
		
		if Input.is_action_just_pressed("jump") and (!is_attacking) and is_on_floor():
			vertical_velocity = Vector3.UP * jump_force
		
		angular_acceleration = 10
		movement_speed = 0
		acceleration = 15
		var h_rotation = cam_rotation_h.global_transform.basis.get_euler().y
		if (Input.is_action_pressed("forward") || Input.is_action_pressed("down") || Input.is_action_pressed("left") || Input.is_action_pressed("right")):
			direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
				0,
				Input.get_action_strength("forward") - Input.get_action_strength("down"))
			direction = direction.rotated(Vector3.UP, h_rotation).normalized()
			if Input.is_action_pressed("sprint") and is_walking:
				movement_speed = run_speed
				is_running = true
			else:
				is_walking = true
				movement_speed = walk_speed
		else:
			is_walking = false
			is_running = false
		
		if Input.is_action_pressed("aim"):
			rotation.y = lerp_angle(rotation.y, cam_rotation_h.rotation.y, delta * angular_acceleration)
		else:
			rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * acceleration)
		
		if is_attacking:
			horizontal_velocity = horizontal_velocity.lerp(direction.normalized() * 0.1, acceleration * delta)
		else:
			horizontal_velocity = horizontal_velocity.lerp(direction.normalized() * movement_speed, acceleration * delta)
		velocity.z = horizontal_velocity.z + vertical_velocity.z
		velocity.x = horizontal_velocity.x + vertical_velocity.x
		velocity.y = vertical_velocity.y
		move_and_slide()
