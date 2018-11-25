extends Node

var ship setget set_current_ship, get_current_ship

signal player_ship_changed(ship)


func set_current_ship(s):
	ship = s;
	Core.gameState.playerShip = s;
	emit_signal('player_ship_changed', ship)

func get_current_ship():
	return ship;