extends CharacterBody3D

const SPEED = 3.0
const FRICTION = 0.04
const DASH_SPEED = 7.
const DASH_TIME = 0.1
const MAX_ROTATION = PI / 16

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var left_input: String
var right_input: String
var up_input: String
var down_input: String
var action_input: String

var _is_dashing: bool = false
var _dash_cooldown: Cooldown
var _dash_direction: Vector3

func _ready():
	_dash_cooldown = $DashCooldown

func set_input(index):
	left_input = "p" + str(index) + "_left"
	up_input = "p" + str(index) + "_up"
	down_input = "p" + str(index) + "_down"
	right_input = "p" + str(index) + "_right"
	action_input = "p" + str(index) + "_action"

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed(action_input) and _dash_cooldown.use_cooldown():
		_is_dashing = true
		_dash_direction = -Vector3(cos(-rotation.y - PI / 2), 0., sin(-rotation.y - PI / 2)).normalized()
		get_tree().create_timer(DASH_TIME).timeout.connect(func(): _is_dashing = false)

	if _is_dashing:
		velocity.x = _dash_direction.x * DASH_SPEED
		velocity.z = _dash_direction.z * DASH_SPEED
	else:
		var input_dir = Input.get_vector(left_input, right_input, up_input, down_input)
	
		if input_dir:
			var angle = -atan2(input_dir.y, input_dir.x) + PI / 2
			
			var diff = atan2(sin(angle-rotation.y), cos(angle-rotation.y))
			if abs(diff) < MAX_ROTATION:
				rotation.y = angle
			else:
				rotation.y += MAX_ROTATION * sign(diff)

			velocity.x += input_dir.x * SPEED
			velocity.z += input_dir.y * SPEED
		
		var factor = velocity.length_squared()
		var old_y = velocity.y
		velocity = velocity.move_toward(Vector3(0, 0, 0), factor * FRICTION)
		velocity.y = old_y
			
	
	move_and_slide()
