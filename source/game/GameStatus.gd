extends Node

## Convenience
var currentScene = null;

var galacticTime = null;
var player = null;

### Player Ship

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


### Other settings (might be taken out of this at some point?)
var cameraMode = null;


### Serialization

const Character = preload('Character.tscn')
const Ship = preload('Ship.tscn')
const GalacticTime = preload('GalacticTime.gd')

func save_game():
	var file = File.new()
	if file.open('user://save_game.wrdr', File.WRITE) != OK:
		return null;
	
	file.store_var(galacticTime.serialize());
	
	file.store_var(playerShipID)
	var ships = Core.outsideWorldSim.get_ships_to_save();
	file.store_var(ships.size())
	for ship in ships:
		file.store_var(ship.serialize())

	Core.sectorsMgr.serialize();
	Core.systemsMgr.serialize();

	return true;

func load_save(root):
	var file = File.new()
	if file.open('user://save_game.wrdr', File.READ) != OK:
		return null;

	galacticTime = GalacticTime.new(0,0,0,0,0)
	galacticTime.deserialize(file.get_var());

	playerShipID = file.get_var()
	var nbships = file.get_var()
	for i in range(0, nbships):
		var ship = Ship.instance()
		ship.deserialize(file.get_var())
		Core.outsideWorldSim.deserialize_ship(ship)
	player = Character.instance()
	player.ship = Core.outsideWorldSim.ship(playerShipID)
	
	root.add_child(player)
	return true
