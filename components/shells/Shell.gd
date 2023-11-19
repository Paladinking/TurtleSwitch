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

static func get_power(shell: Shell, is_dashing: bool):
	var kind = Kind.NONE
	if shell != null:
		kind = shell.kind
	if is_dashing:
		match kind:
			Kind.POWER:
				return 25
			_:
				return 15
	match kind:
		Kind.NONE:
			return 3
		Kind.BASIC:
			return 5
		Kind.POWER:
			return 10
		Kind.GOLDEN:
			return 2

static func has_bash(shell: Shell):
	return shell != null and shell.kind == Kind.BASIC

static func get_acceleration(shell: Shell):
	var kind = Kind.NONE
	if shell != null:
		kind = shell.kind
	match kind:
		Kind.NONE:
			return 3.0
		Kind.BASIC:
			return 4.0
		Kind.POWER:
			return 3.0
		Kind.GOLDEN:
			return 0.5

static func get_dash_speed(shell: Shell):
	var kind = Kind.NONE
	if shell != null:
		kind = shell.kind
	match kind:
		Kind.NONE:
			return 9.0
		Kind.BASIC:
			return 13.0
		Kind.POWER:
			return 16.0
		Kind.GOLDEN:
			return 10.0

static func get_action(shell: Shell):
	if shell != null and shell.kind == Kind.BASIC:
		return Turtle.Action.DASH
	return Turtle.Action.DASH

static func get_hp(shell: Shell):
	return 20
