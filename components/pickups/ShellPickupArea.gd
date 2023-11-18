class_name ShellPickupArea
extends Area3D

@export
var shell_type: Shell.Kind


func collect_pickup():
	get_parent().queue_free()
	return shell_type
