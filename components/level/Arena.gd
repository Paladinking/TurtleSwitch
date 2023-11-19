class_name Arena
extends Node3D

var layouts_in_action: Array = []
var layouts_going_away: Array = []

const INACTIVE_LAYOUT_HEIGHT = -10.
const ACTIVE_LAYOUT_HEIGHT = 0.

const LAYOUT_CHANGE_SPEED = 10.
const LOWEST_CHANGE_SPEED = 0.1
const CHANGE_SPEED_FACTOR = 3.


	
func _ready():
	$TopDirectionIndicator.hide()


func _physics_process(delta):
	for layout in layouts_in_action:
		if layout.position.y >= ACTIVE_LAYOUT_HEIGHT:
			layout.position.y = ACTIVE_LAYOUT_HEIGHT
			layouts_in_action.erase(layout)
		else:
			var speed = LAYOUT_CHANGE_SPEED * delta * (max(abs(layout.position.y), LOWEST_CHANGE_SPEED) / CHANGE_SPEED_FACTOR)
			layout.position.y += speed

	for layout in layouts_going_away:
		if layout.position.y <= INACTIVE_LAYOUT_HEIGHT:
			layout.position.y = INACTIVE_LAYOUT_HEIGHT
			layouts_going_away.erase(layout)
		else:
			var speed = LAYOUT_CHANGE_SPEED * delta * (max(abs(layout.position.y), LOWEST_CHANGE_SPEED) / CHANGE_SPEED_FACTOR)
			layout.position.y -= speed



func engage_layout(layout_name: String):
	var layout = get_node(layout_name) as Node3D

	if layout not in layouts_in_action:
		layouts_in_action.append(layout)
		if layout in layouts_going_away:
			layouts_going_away.erase(layout)



func disengage_layout(layout_name: String):
	var layout = get_node(layout_name) as Node3D

	if layout not in layouts_going_away:
		layouts_going_away.append(layout)
		if layout in layouts_in_action:
			layouts_in_action.erase(layout)
