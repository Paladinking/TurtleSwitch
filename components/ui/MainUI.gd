@tool
extends Control
class_name MainUI

const MAX_NUMBER_OF_PLAYERS = 4

@export_range(2, MAX_NUMBER_OF_PLAYERS)
var number_of_players: int = 2:
	set(v):
		number_of_players = v
		set_number_of_players(v)



func set_number_of_players(n : int):
	
	for i in range(1, MAX_NUMBER_OF_PLAYERS + 1):
		if i <= n:
			get_node("PlayerLabel" + str(i)).show()
		else:
			get_node("PlayerLabel" + str(i)).hide()

func show_victory(player_number: int):
	$Victory.text = "Player " + str(player_number + 1) + " won!!!"
	$Victory.show()

func increase_player_points(player_number : int, points : int):
	if 0 <= player_number and player_number < MAX_NUMBER_OF_PLAYERS:
		get_node("PlayerLabel" + str(player_number + 1)).increase_points(points)


func set_player_points(player_number : int, points : int):
	if 0 <= player_number and player_number < MAX_NUMBER_OF_PLAYERS:
		get_node("PlayerLabel" + str(player_number + 1)).set_points(points)



func get_player_points(player_number : int):
	if 0 <= player_number and player_number < MAX_NUMBER_OF_PLAYERS:
		return get_node("PlayerLabel" + str(player_number + 1)).get_points()

