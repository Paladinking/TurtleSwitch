class_name Turtle
extends CharacterBody3D

const COLLISION_DURATION = 0.2
const MAX_VELOCITY = 11.0
const FRICTION = 0.04
const DASH_TIME = 0.2
const BASH_TIME = 1.2
const MAX_ROTATION = PI / 16
const MIN_SPEED_FOR_ANIMATION = 5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var left_input: String
var right_input: String
var up_input: String
var down_input: String
var action_input: String

var _collision_acceleration = Vector3(0, 0, 0)
var _dash_cooldown: Cooldown
var _bash_cooldown: Cooldown
var _bash_area: Area3D
var _action_direction: Vector3
var _shell: Shell = null:
	set(new_shell):
		if _shell != null:
			_shell.queue_free()
		
		new_shell.reparent(self)
		new_shell.position = Vector3(0, 0, 0)
		new_shell.rotation = Vector3(0, 0, 0)
		_shell = new_shell

var on_ice : bool = false
var in_mud : bool = false
var _was_on_floor: bool = false

enum Action {
	NONE,
	DASH,
	BASH
}

var _action : Action = Action.NONE

func _ready():
	_dash_cooldown = $DashCooldown
	_bash_cooldown = $BashCooldown
	_bash_area = $BashArea
	$PickupDetector.area_entered.connect(
		func(area: Area3D):
			if area is ShellPickupArea:
				_shell = area.get_pickup().pick_up()
				
	)

	$Model/AnimationPlayer.get_animation("ArmatureAction").loop_mode = Animation.LOOP_LINEAR

func set_input(index):
	left_input = "p" + str(index) + "_left"
	up_input = "p" + str(index) + "_up"
	down_input = "p" + str(index) + "_down"
	right_input = "p" + str(index) + "_right"
	action_input = "p" + str(index) + "_action"

func turtle_collision(power, dir):
	_collision_acceleration = power * dir
	get_tree().create_timer(COLLISION_DURATION, true, true).timeout.connect(
		func(): _collision_acceleration = Vector3(0, 0, 0)
	)

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed(action_input):
		var action = Shell.get_action(_shell)
		if action == Action.DASH and _dash_cooldown.use_cooldown():
			_action = Action.DASH
			_action_direction = -(
				Vector3(cos(rotation.y + PI), 0., sin(rotation.y)).normalized()
			)
			get_tree().create_timer(DASH_TIME, true, true).timeout.connect(func(): _action = Action.NONE)
		elif action == Action.BASH and _bash_cooldown.use_cooldown():
			_action = Action.BASH
			_action_direction = -(
				Vector3(cos(rotation.y + PI), 0., sin(rotation.y)).normalized()
			) * 0.3
			velocity.y = 30
			gravity = gravity * 15
			# Needed in case turtle gets stuck on wall
			get_tree().create_timer(BASH_TIME, true, true).timeout.connect(
				func():
					if _action == Action.NONE:
						return
					_action = Action.NONE
					gravity = gravity / 15
			)

	if _action == Action.DASH or _action == Action.BASH:
		var factor = 1.0

		if on_ice:
			factor *= 1.5
		elif in_mud:
			factor /= 1.5

		var dash_speed = Shell.get_dash_speed(_shell)
		velocity.x = _action_direction.x * dash_speed * factor
		velocity.z = _action_direction.z * dash_speed * factor
		
		var animator = $Model/AnimationPlayer
		if animator.is_playing():
			animator.pause()
		
		if !_was_on_floor and is_on_floor() and _action == Action.BASH:
			_action = Action.NONE
			gravity = gravity / 15

			for body in _bash_area.get_overlapping_bodies():
				if body is Turtle and body != self:
					body.turtle_collision(15, body.position - position)
				if body is ShellPickup:
					body.apply_force(50 * body.position - position)

	else:
		var input_dir = Input.get_vector(left_input, right_input, up_input, down_input)

		if input_dir:
			var angle = -atan2(input_dir.y, input_dir.x)
			
			var diff = atan2(sin(angle-rotation.y), cos(angle-rotation.y))
			if abs(diff) < MAX_ROTATION:
				rotation.y = angle
			else:
				rotation.y += MAX_ROTATION * sign(diff)
			var acc = Shell.get_acceleration(_shell)
			velocity.x += input_dir.x * acc
			velocity.z += input_dir.y * acc

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
		
		var animator = $Model/AnimationPlayer
		if velocity.length_squared() > MIN_SPEED_FOR_ANIMATION:
			if not animator.is_playing():
				animator.play("ArmatureAction")
		else:
			animator.pause()
	
	velocity += _collision_acceleration
	_collision_acceleration *= 0.9
	var collision_info = move_and_collide(velocity * delta, true)
	if collision_info:
		for i in collision_info.get_collision_count():
			var collider = collision_info.get_collider(i)
			if collider is Turtle:
				var power = Shell.get_power(_shell, _action == Action.DASH)
				collider.turtle_collision(power, -collision_info.get_normal(i))
			elif collider is ShellPickup:
				collider.apply_force(10 * velocity.length() * -collision_info.get_normal(i))
			#elif abs(collision_info.get_normal(i).y) < 0.1 and velocity.length_squared() > 200:
			#	velocity = -velocity * 0.8
			#	_dash_direction = -_dash_direction
			#	rotate_y(PI)
	_was_on_floor = is_on_floor()
	move_and_slide()

func pick_up(shell: Shell):
	_shell = shell
