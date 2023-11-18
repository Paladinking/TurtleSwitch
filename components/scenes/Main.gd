extends Node3D

const INPUT_NAMES = [
	"left", "right", "up", "down"
]

const CONTROLLER_INPUTS = [
	[JOY_BUTTON_DPAD_LEFT, JOY_AXIS_LEFT_X, -1.0],
	[JOY_BUTTON_DPAD_RIGHT, JOY_AXIS_LEFT_X, 1.0],
	[JOY_BUTTON_DPAD_UP, JOY_AXIS_LEFT_Y, -1.0],
	[JOY_BUTTON_DPAD_DOWN, JOY_AXIS_LEFT_Y, 1.0]
]

const KEYBOARD_INPUTS = [
	[KEY_LEFT, KEY_A],
	[KEY_RIGHT, KEY_D],
	[KEY_UP, KEY_W],
	[KEY_DOWN, KEY_S]
]

func _ready():
	var joypads = Input.get_connected_joypads()
	
	var players = get_meta("Players")
	for index in players.size():
		var player = get_node(players[index])
		for i in INPUT_NAMES.size():
			var name = "p" + str(index) + "_" + INPUT_NAMES[i]
			InputMap.add_action(name)
			if index < joypads.size():
				var ev1 = InputEventJoypadButton.new()
				ev1.button_index = CONTROLLER_INPUTS[i][0]
				ev1.device = joypads[index]
				InputMap.action_add_event(name, ev1)
				var ev2 = InputEventJoypadMotion.new()
				ev2.axis = CONTROLLER_INPUTS[i][1]
				ev2.axis_value = CONTROLLER_INPUTS[i][2]
				ev2.device = joypads[index]
				InputMap.action_add_event(name, ev2)
			elif index == joypads.size():
				for key in KEYBOARD_INPUTS[i]:
					var ev = InputEventKey.new()
					ev.keycode = key
					InputMap.action_add_event(name, ev)

		player.set_input(index)


func _unhandled_key_input(event):
	if event.is_pressed() and event.keycode == KEY_ESCAPE:
		get_tree().quit(0)
