class_name Turtle
extends CharacterBody3D

const ACCELERATION = 3.0
const MAX_VELOCITY = 11.0
const FRICTION = 0.04
const DASH_SPEED = 14.
const DASH_TIME = 0.2
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
var _shell: Shell = null:
	set(new_shell):
		if _shell != null:
			_shell.queue_free()
			
		add_child(new_shell)
		_shell = new_shell

var on_ice : bool = false
var in_mud : bool = false

func _ready():
	_dash_cooldown = $DashCooldown
	$PickupDetector.area_entered.connect(
		func(area: Area3D):
			if area is ShellPickupArea:
				pick_up(area.collect_pickup())
	)

	$Model/AnimationPlayer.get_animation("ArmatureAction").loop_mode = Animation.LOOP_LINEAR
	$Model/AnimationPlayer.play("ArmatureAction")


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
		_dash_direction = -(
			Vector3(cos(rotation.y + PI), 0., sin(rotation.y)).normalized()
		)
		get_tree().create_timer(DASH_TIME, true, true).timeout.connect(func(): _is_dashing = false)

	if _is_dashing:
		var factor = 1.0

		if on_ice:
			factor *= 1.5
		elif in_mud:
			factor /= 1.5

		velocity.x = _dash_direction.x * DASH_SPEED * factor
		velocity.z = _dash_direction.z * DASH_SPEED * factor
	else:
		var input_dir = Input.get_vector(left_input, right_input, up_input, down_input)

		if input_dir:
			var angle = -atan2(input_dir.y, input_dir.x)
			
			var diff = atan2(sin(angle-rotation.y), cos(angle-rotation.y))
			if abs(diff) < MAX_ROTATION:
				rotation.y = angle
			else:
				rotation.y += MAX_ROTATION * sign(diff)

			velocity.x += input_dir.x * ACCELERATION
			velocity.z += input_dir.y * ACCELERATION

		var factor = velocity.x * velocity.x + velocity.z * velocity.z
		var old_y = velocity.y
		
		var friction = FRICTION

		if on_ice:
			friction /= 20
		elif in_mud:
			friction *= 2
			
		velocity = velocity.move_toward(Vector3(0, 0, 0), factor * friction)

		if factor > MAX_VELOCITY * MAX_VELOCITY:
			var length = sqrt(factor)
			velocity.x = velocity.x / length * MAX_VELOCITY
			velocity.z = velocity.z / length * MAX_VELOCITY
		velocity.y = old_y
	
	move_and_slide()

func pick_up(shell_type: Shell.Kind):
	_shell = Shell.from_kind(shell_type)
