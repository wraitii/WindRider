extends Node

var player = null;

var playerShip = null setget set_player_ship, get_player_ship;
var playerShipID = null setget set_player_ship_id, get_player_ship_id;

func set_player_ship(ship):
	playerShip = ship;
	playerShipID = ship.ID

func get_player_ship(): return playerShip;

func set_player_ship_id(ID):
	playerShip = Core.outsideWorldSim.ship(ID);

	playerShipID = ID

func get_player_ship_id(): return playerShipID;

# used to know which system to instance
var currentSystem = null;
var currentScene = null;



var cameraMode = null;