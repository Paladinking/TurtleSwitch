@tool
class_name ShellPickup
extends RigidBody3D

@export
var kind: Shell.Kind:
	set(new_kind):
		update_shell_kind(new_kind)
		kind = new_kind
		
func _ready():
	update_shell_kind(kind)
	$Area3D.process_mode = Node.PROCESS_MODE_DISABLED
	collision_layer = 0
	
func _physics_process(delta):
	if pickup_delay <= 0:
		$Area3D.process_mode = Node.PROCESS_MODE_INHERIT
		collision_layer = 1
	else:
		pickup_delay -= delta
		
		
	
func update_shell_kind(kind: Shell.Kind):
	if shell:
		shell.kind = kind


@onready
var shell: Shell = $Shell
var pickup_delay = 1.0

func pick_up() -> Shell:
	queue_free()
	return shell
