@tool
extends Node3D

@export_range(0.1, 10.)
var radius: float = 5:
	set(v):
		radius = v
		$MeshInstance3D.mesh.top_radius = v
		$MeshInstance3D.mesh.bottom_radius = v
		$Area3D/CollisionShape3D.shape.radius = v
#		update_configuration_warnings()


# !DO NOT! make multiple Mud pits overlap, exiting one will remove in_mud
# even if they are still on another


func _ready():
#	$MeshInstance3D.mesh.top_radius = radius
#	$MeshInstance3D.mesh.bottom_radius = radius
#	$Area3D/CollisionShape3D.shape.radius = radius

	var area = $Area3D as Area3D
	
	area.body_entered.connect(
		func(body : Node3D):
			if (body is Turtle):
				body.in_mud = true
	)
	area.body_exited.connect(
		func(body : Node3D):
			if (body is Turtle):
				body.in_mud = false
	)

	#if Engine.is_editor_hint():
	#	return
	#	
