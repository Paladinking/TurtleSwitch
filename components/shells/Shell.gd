class_name Shell

enum Kind {
	NONE,
	BASIC,
}

const _empty_shell = preload("res://components/shells/EmptyShell.tscn")
const _basic_shell = preload("res://components/shells/BasicShell.tscn")

static func instantiate(kind : Kind):
	if kind == Kind.BASIC:
		return _basic_shell.instantiate()
	return _empty_shell.instantiate()
