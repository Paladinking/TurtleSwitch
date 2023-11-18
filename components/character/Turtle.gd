extends CharacterBody3D


const SPEED = 4.0
const DASH_SPEED = 7.
const DASH_TIME = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var left_input: String
var right_input: String
var up_input: String
var down_input: String
var action_input: String

var _is_dashing: bool = false
var _dash_cooldown: Cooldown

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
		get_tree().create_timer(DASH_TIME).timeout.connect(func(): _is_dashing = false)

	if _is_dashing:
		var dash_direction = Vector3(1., 0., 0.)
		velocity.x = dash_direction.x * DASH_SPEED
		velocity.z = dash_direction.z * DASH_SPEED

		move_and_slide()
	else:
		var input_dir = Input.get_vector(left_input, right_input, up_input, down_input)
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()
