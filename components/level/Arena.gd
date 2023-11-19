class_name Arena
extends Node3D

var layouts_in_action: Array = []
var layouts_going_away: Array = []

static var INACTIVE_LAYOUT_HEIGHT = -10
static var ACTIVE_LAYOUT_HEIGHT = 0
static var LAYOUT_CHANGE_SPEED = 0.1


func _ready():
	$TopDirectionIndicator.hide()


func _process(_delta):
	for layout in layouts_in_action:
		if layout.position.y >= ACTIVE_LAYOUT_HEIGHT:
			layout.position.y = ACTIVE_LAYOUT_HEIGHT
			layouts_in_action.erase(layout)
		else:
			layout.position.y += LAYOUT_CHANGE_SPEED

	for layout in layouts_going_away:
		if layout.position.y <= INACTIVE_LAYOUT_HEIGHT:
			layout.position.y = INACTIVE_LAYOUT_HEIGHT
			layouts_going_away.erase(layout)
		else:
			layout.position.y -= LAYOUT_CHANGE_SPEED



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
