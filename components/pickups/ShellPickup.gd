@tool
class_name ShellPickup
extends Area3D

@export
var kind: Shell.Kind:
	set(new_kind):
		update_shell_kind(new_kind)
		kind = new_kind
		
func _ready():
	update_shell_kind(kind)
	
	
func update_shell_kind(kind: Shell.Kind):
	if shell:
		shell.kind = kind


@onready
var shell: Shell = $Shell

func pick_up() -> Shell:
	queue_free()
	return shell
