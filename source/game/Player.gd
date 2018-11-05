extends Node

var playerShip setget setCurrentShip, get_current_ship

func _ready():
	playerShip = get_node("/root/InGameRoot/Ship")
	pass

func setCurrentShip(ship):
	playerShip = ship;

func get_current_ship():
	return playerShip;
