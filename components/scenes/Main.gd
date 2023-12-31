class_name Main
extends Node3D

const INPUT_NAMES = ["left", "right", "up", "down", "action", "jump"]

@onready
var golden_shell: Shell = $Level/GoldenShell/Shell

@onready
var main_ui: MainUI = $MainUI

var change = 0

const JOY_AXIS_INPUTS = [
	[[JOY_AXIS_LEFT_X, -1.0]],
	[[JOY_AXIS_LEFT_X, 1.0]],
	[[JOY_AXIS_LEFT_Y, -1.0]],
	[[JOY_AXIS_LEFT_Y, 1.0]],
	[],
	[]
]

const JOY_BUTTON_INPUTS = [
	[JOY_BUTTON_DPAD_LEFT],
	[JOY_BUTTON_DPAD_RIGHT],
	[JOY_BUTTON_DPAD_UP],
	[JOY_BUTTON_DPAD_DOWN],
	[JOY_BUTTON_X],
	[JOY_BUTTON_A]
]

const KEYBOARD_INPUTS = [
	[KEY_LEFT, KEY_A],
	[KEY_RIGHT, KEY_D],
	[KEY_UP, KEY_W],
	[KEY_DOWN, KEY_S],
	[KEY_E],
	[KEY_SPACE]
]


@onready
var arena = $Level/Arena
@onready
var level = $Level

var timeout: float = 1.0

func _ready():
	var joypads = Input.get_connected_joypads()
	var turtles: Array = $Turtles.get_children()

	var count = turtles.size()
	for index in turtles.size():
		var player = turtles[index]
		
		for i in INPUT_NAMES.size():
			var input_name = "p%s_%s" % [index, INPUT_NAMES[i]]
			
			InputMap.add_action(input_name)
			
			if index < joypads.size():
				for button in JOY_BUTTON_INPUTS[i]:
					var ev = InputEventJoypadButton.new()
					ev.button_index = button
					ev.device = joypads[index]
					InputMap.action_add_event(input_name, ev)
					
				for joy_axis in JOY_AXIS_INPUTS[i]:
					var ev = InputEventJoypadMotion.new()
					ev.axis = joy_axis[0]
					ev.axis_value = joy_axis[1]
					ev.device = joypads[index]
					InputMap.action_add_event(input_name, ev)
			elif index == joypads.size():
				for key in KEYBOARD_INPUTS[i]:
					var ev = InputEventKey.new()
					ev.keycode = key
					InputMap.action_add_event(input_name, ev)

		if index > joypads.size():
			count -= 1
			player.queue_free()
		
		player.set_input(index)
	main_ui.number_of_players = count
	for i in count:
		main_ui.increase_player_points(i, 0)
	
func _process(_delta):
	timeout -= _delta
	if timeout <= 0:
		timeout = 1.0
		for player in $Turtles.get_children():
			if player._shell != null and player._shell.kind == Shell.Kind.GOLDEN:
				main_ui.increase_player_points(player.id, 1)
				if main_ui.get_player_points(player.id) >= 60:
					main_ui.show_victory(player.id)
					$MainUI.process_mode = Node.PROCESS_MODE_ALWAYS
					get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED
				break
	if is_instance_valid(golden_shell):
		
			
		pass#$Graphics/SpotLight3D.look_at(golden_shell.global_position)



var hazards_active = false

func change_hazards():
	if hazards_active:
		$Level/Arena.disengage_layout("IceAndMud")
	else:
		$Level/Arena.engage_layout("IceAndMud")
		
	hazards_active = !hazards_active
	
func change_layout(l):
	if l % 2 == 1:
		$Level/Arena.disengage_layout("PillAndHillars")
		$Level/Arena.engage_layout("HillAndPillars")
	else:
		$Level/Arena.disengage_layout("HillAndPillars")
		$Level/Arena.engage_layout("PillAndHillars")
	



#func _unhandled_key_input(event):
#	if event.is_pressed() and event.keycode == KEY_ESCAPE:
#		get_tree().quit(0)
#
#	elif event.is_pressed() and event.keycode == KEY_I:
##		print("Engaging layout")
#		arena.engage_layout("HillAndPillars")
#
#	elif event.is_pressed() and event.keycode == KEY_O:
##		print("Disengaging layout")
#		arena.disengage_layout("HillAndPillars")
#
#	elif event.is_pressed() and event.keycode == KEY_K:
##		print("Engaging layout")
#		arena.engage_layout("IceAndMud")
#
#	elif event.is_pressed() and event.keycode == KEY_L:
##		print("Disengaging layout")
#		arena.disengage_layout("IceAndMud")


func _on_timer_timeout():
	change += 1
	if change % 2 == 0:
		change_layout(change / 2)
	change_hazards()
