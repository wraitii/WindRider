extends Node

signal player_ship_changed(ship)

var ship setget set_current_ship, get_current_ship

var credits = 0;

# Array of target - Opinion
var relations = {}

func set_current_ship(s):
	ship = s;
	Core.gameState.playerShip = s;
	emit_signal('player_ship_changed', ship)

func get_current_ship():
	return ship;