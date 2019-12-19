extends 'Society.gd'

signal player_ship_changed(ship)

var ship setget set_current_ship, get_current_ship

func set_current_ship(s):
	ship = s;
	if self == Core.gameState.player:
		Core.gameState.playerShip = s;
		emit_signal('player_ship_changed', ship)

func get_current_ship():
	return ship;
