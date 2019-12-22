extends Node

## Convenience
var currentScene = null;

var galacticTime = null;
var player = null;

### Player Ship

var playerShip = null setget set_player_ship, get_player_ship;

func set_player_ship(ship):
	playerShip = ship;

func get_player_ship(): return playerShip;

### Other settings (might be taken out of this at some point?)
var cameraMode = null;

const warp_factors = [0.5, 1, 1.5, 2, 4, 8]
var warp_factor = 1;

### Serialization

const Character = preload('Character.tscn')
const Ship = preload('Ship.tscn')
const GalacticTime = preload('GalacticTime.gd')

func save_game():
	var file = File.new()
	if file.open('user://save_game.wdrr', File.WRITE) != OK:
		return null;
	
	file.store_var(Core.societyMgr.serialize())
	file.store_var(Core.landablesMgr.serialize())
	file.store_var(Core.systemsMgr.serialize())
	file.store_var(Core.sectorsMgr.serialize())

	file.store_var(galacticTime.serialize());
	
	file.store_var(playerShip.ID)
	
	file.store_var(Core.outsideWorldSim.serialize());

	return true;

func load_save(root):
	var file = File.new()
	if file.open('user://save_game.wdrr', File.READ) != OK:
		return null;

	Core.societyMgr.deserialize(file.get_var())
	Core.landablesMgr.deserialize(file.get_var())
	Core.systemsMgr.deserialize(file.get_var())
	Core.sectorsMgr.deserialize(file.get_var())

	galacticTime = GalacticTime.new(0,0,0,0,0)
	galacticTime.deserialize(file.get_var());

	var playerShipID = file.get_var()
	Core.outsideWorldSim.deserialize(file.get_var());
	
	## TODO: fetch from the societies
	player = Character.instance()
	player.ship = Core.outsideWorldSim.ship(playerShipID)
	
	root.add_child(player)
	return true
