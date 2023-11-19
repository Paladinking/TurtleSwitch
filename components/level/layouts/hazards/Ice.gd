@tool
extends Node3D

@export_range(0.1, 10.)
var size: float = 1:
	set(v):
		size = v
		scale = Vector3(size, 1., size)


# !DO NOT! make multiple Ice sheets overlap, exiting one will remove on_ice
# even if they are still on another


func _ready():
	if Engine.is_editor_hint():
		return

	var area = $Area3D as Area3D
	
	area.body_entered.connect(
		func(body : Node3D):
			if (body is Turtle):
				body.on_ice = true
	)
	area.body_exited.connect(
		func(body : Node3D):
			if (body is Turtle):
				body.on_ice = false
	)
