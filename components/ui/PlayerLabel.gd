@tool
extends Label


@export_range(1, 4)
var player_number: int = 1:
	set(v):
		player_number = v
		set_player(str(v))


func set_player(player: String):
	text = " Player " + player + ": "


func increase_points(points):
	$PointsLabel.text = str(get_points() + points)


func set_points(points : int):
	$PointsLabel.text = str(points)


func get_points():
	return int($PointsLabel.text)
