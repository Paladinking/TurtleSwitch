@tool
class_name ShellPickup
extends RigidBody3D

@export
var kind: Shell.Kind:
	set(new_kind):
		$Shell.kind = new_kind
		kind = new_kind
		
func _ready():
	$ShellPickupArea.shell_type = kind
