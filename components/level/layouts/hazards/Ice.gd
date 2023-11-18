@tool
extends Node3D

@export_range(0.1, 10.)
var radius: float = 5:
	set(v):
		radius = v
		print($MeshInstance3D)
		$MeshInstance3D.mesh.top_radius = v
		$MeshInstance3D.mesh.bottom_radius = v
		$Area3D/CollisionShape3D.shape.radius = v
		update_configuration_warnings()


func _ready():
	if Engine.is_editor_hint():
		return

	var area = $Area3D as Area3D
	
	area.body_entered.connect(
		func(body: Node3D):
			if (body is Turtle):
				body.on_ice = true
	)
	area.body_exited.connect(
		func(body: Node3D):
			if (body is Turtle):
				body.on_ice = false
	)
