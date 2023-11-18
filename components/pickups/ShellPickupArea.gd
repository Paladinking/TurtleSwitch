class_name ShellPickupArea
extends Area3D

@export
var shell_type: Shell.Kind


func get_shell():
	return get_parent()
