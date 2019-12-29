extends 'Society.gd'

signal player_ship_changed(ship)

var ship setget set_current_ship, get_current_ship

var ongoing_missions = []

## TODO: transfer signals

func set_current_ship(s):
	if ship:
		ship.ownerChar = null
	ship = s;
	ship.ownerChar = self
	if self == Core.gameState.player:
		Core.gameState.playerShip = s;
		emit_signal('player_ship_changed', ship)

func get_current_ship():
	return ship;
