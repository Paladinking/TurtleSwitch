class_name Turtle
extends CharacterBody3D

const COLLISION_DURATION = 0.2
const MAX_VELOCITY = 11.0
const FRICTION = 0.04
const BASH_TIME = 1.2
const MAX_ROTATION = PI / 16
const MIN_SPEED_FOR_ANIMATION = 5

const SHELL_PICKUP = preload("res://components/pickups/ShellPickup.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 15 * ProjectSettings.get_setting("physics/3d/default_gravity")
var left_input: String
var right_input: String
var up_input: String
var down_input: String
var action_input: String
var jump_input: String
var id: int = -1

var _collision_acceleration = Vector3(0, 0, 0)
var _dash_cooldown: Cooldown
var _bash_cooldown: Cooldown
var _stun_cooldown: Cooldown
var _bash_area: Area3D
var _action_direction: Vector3
var _shell: Shell = null:
	set(new_shell):
		if new_shell != null:
			_action = Action.CRAWL_IN
			new_shell.position = Vector3(0, 0, 0)
			new_shell.rotation = Vector3(0, 0, 0)

		_shell = new_shell
var _shell_hp: int = 0

var on_ice : bool = false
var in_mud : bool = false
var _was_on_floor: bool = false

enum Action {
	NONE,
	WALK,
	DASH,
	BASH,
	CRAWL_IN,
}

var action_animations = {
	Action.NONE: "Idle",
	Action.WALK: "Walk",
	Action.DASH: "Dash",
	Action.BASH: "Jump",
	Action.CRAWL_IN: "krypa_in",
}

var _action : Action = Action.NONE

func _ready():
	_dash_cooldown = $DashCooldown
	_bash_cooldown = $BashCooldown
	_stun_cooldown = $StunCooldown
	_bash_area = $BashArea
	$PickupDetector.area_entered.connect(
		func(area: Area3D):
			if area is ShellPickupArea:
				if _shell != null:
					drop_shell(-transform.basis.x * 20)
				var s = area.get_pickup().pick_up()
				s.reparent(self)
				_shell = s
				_shell_hp = Shell.get_hp(_shell)
				
	)

	$Model/AnimationPlayer.get_animation("Dash").loop_mode = Animation.LOOP_LINEAR
	$Model/AnimationPlayer.get_animation("Idle").loop_mode = Animation.LOOP_LINEAR
	$Model/AnimationPlayer.get_animation("Walk").loop_mode = Animation.LOOP_LINEAR
	$Model/AnimationPlayer.get_animation("Jump").loop_mode = Animation.LOOP_LINEAR
	$Model/AnimationPlayer.animation_finished.connect(
		func (anim_name):
			if anim_name == "krypa_in":
				_action = Action.NONE
	)
	_stun_cooldown.on_cooldown_begin.connect(
		func():
			print("cooldown begin")
			$stars.show()
			$stars/AnimationPlayer.play("stjarnor")
	)
	$stars/AnimationPlayer.animation_finished.connect(
		func(_anim):
			$stars.hide()
	)
	$stars.hide()

func set_input(index):
	left_input = "p" + str(index) + "_left"
	up_input = "p" + str(index) + "_up"
	down_input = "p" + str(index) + "_down"
	right_input = "p" + str(index) + "_right"
	action_input = "p" + str(index) + "_action"
	jump_input = "p" + str(index) + "_jump"
	id = index


func drop_shell(dir: Vector3):
	var pickup = SHELL_PICKUP.instantiate()
	remove_child(_shell)
	pickup.add_child(_shell)
	pickup.position = position
	pickup.apply_force(dir)
	pickup.kind = _shell.kind
	get_tree().current_scene.level.add_child(pickup)
	pickup.shell.update_shell_visibility()
	_shell = null


func turtle_collision(power, dir):
	if _collision_acceleration:
		return
	if _shell != null:
		_shell_hp -= power
		if _shell_hp < 0:
			drop_shell(dir * power * 10)
			_stun_cooldown.reset()
			return
	_collision_acceleration = power * dir
	get_tree().create_timer(COLLISION_DURATION, true, true).timeout.connect(
		func(): _collision_acceleration = Vector3(0, 0, 0)
	)
	
			

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	var animator: AnimationPlayer = $Model/AnimationPlayer
	
	var is_controlling = _action != Action.CRAWL_IN and _stun_cooldown.is_done()
	
	if not is_controlling:
		velocity.x = 0
		velocity.z = 0
	else:
		if Input.is_action_just_pressed(action_input):
			var action = Shell.get_action(_shell)
			if action == Action.DASH and _dash_cooldown.use_cooldown():
				_action = Action.DASH
				_action_direction = -(
					Vector3(cos(rotation.y + PI), 0., sin(rotation.y)).normalized()
				)
				var dash_time = Shell.get_dash_time(_shell)
				get_tree().create_timer(dash_time, true, true).timeout.connect(func(): _action = Action.NONE)
		if Input.is_action_just_pressed(jump_input) and _bash_cooldown.use_cooldown():
			_action = Action.BASH
			_action_direction = -(
				Vector3(cos(rotation.y + PI), 0., sin(rotation.y)).normalized()
			) * 0.3
			velocity.y = 30
				
		# Needed in case turtle gets stuck on wall
		if _action == Action.BASH and _bash_cooldown.is_done():
			_action = Action.NONE 

		if _action == Action.DASH or _action == Action.BASH:
			var factor = 1.0

			if on_ice:
				factor *= 1.5
			elif in_mud:
				factor /= 1.5

			var dash_speed = Shell.get_dash_speed(_shell)
			velocity.x = _action_direction.x * dash_speed * factor
			velocity.z = _action_direction.z * dash_speed * factor
			
			if !_was_on_floor and is_on_floor() and _action == Action.BASH:
				_action = Action.NONE
				if Shell.has_bash(_shell):
					for body in _bash_area.get_overlapping_bodies():
						if body is Turtle and body != self:
							var diff = body.position - position
							diff.y = 0
							body.turtle_collision(15, diff)
						if body is ShellPickup:
							var vec = (body.global_position - global_position).normalized()
							body.apply_force(200 * vec)

		elif _stun_cooldown.is_done():
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
			
			if velocity.length_squared() > MIN_SPEED_FOR_ANIMATION:
				_action = Action.WALK
			else:
				_action = Action.NONE
		
	velocity += _collision_acceleration
	_collision_acceleration *= 0.9
	var collision_info = move_and_collide(velocity * delta, true)
	if collision_info:
		for i in collision_info.get_collision_count():
			var collider = collision_info.get_collider(i)
			var dir = (collision_info.get_position(i) - position).normalized()
			if collider is Turtle:
				var power = Shell.get_power(_shell, _action == Action.DASH)
				collider.turtle_collision(power, dir)
			elif collider is ShellPickup:
				collider.apply_force(10 * velocity.length() * dir)
			elif abs(dir.y) < 0.1 and velocity.length_squared() > 120 and _action != Action.BASH:
				var norm = collision_info.get_normal(i)
				var old_y = velocity.y
				velocity = velocity.bounce(norm)
				velocity.y = old_y
				_action_direction = _action_direction.bounce(norm)
				rotation.y = -atan2(velocity.z, velocity.x)
	_was_on_floor = is_on_floor()
	
	# Update animations
	var next_animation = action_animations[_action]
	if animator.current_animation != next_animation:
		animator.play(next_animation)
	
	move_and_slide()

