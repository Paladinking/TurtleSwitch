extends Node3D


func _unhandled_key_input(event):
	if event.is_pressed() and event.keycode == KEY_ESCAPE:
		get_tree().quit(0)
