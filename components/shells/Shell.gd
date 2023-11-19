@tool
class_name Shell
extends Node3D

enum Kind {
	NONE,
	GOLDEN,
	BASIC,
	POWER,
}

@onready
var shells = [$ShellBasic, $ShellPower, $PowerShell, $ShellGolden]

@export
var kind: Kind:
	set(new_kind):
		kind = new_kind
		update_shell_visibility()

const ShellScene = preload("res://components/shells/Shell.tscn")

func _ready():
	update_shell_visibility()

static func from_kind(k : Kind):
	var scene = ShellScene.instantiate()
	scene.kind = k
	return scene

func update_shell_visibility():
	if not shells:
		return
		
	for shell in shells:
		shell.hide()
		
	match kind:
		Kind.NONE:
			pass
		Kind.BASIC:
			$ShellBasic.show()
		Kind.POWER:
			$PowerShell.show()
		Kind.GOLDEN:
			$ShellGolden.show()
