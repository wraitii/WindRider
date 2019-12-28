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

const Character = preload('Character.tscn')
const Ship = preload('Ship.tscn')
const GalacticTime = preload('GalacticTime.gd')

func create_new_game():
	Core.societyMgr.populate()
	Core.landablesMgr.populate()
	Core.systemsMgr.populate()
	Core.sectorsMgr.populate()
	Core.missionsMgr.populate()

	galacticTime = GalacticTime.new(3065, 04, 12, 13, 48)

	var start = Core.missionsMgr.create_resource({ 'type': 'NewGame' })
	start.start()

#### Serialization

func save_game():
	var file = File.new()
	if file.open('user://save_game.wdrr', File.WRITE) != OK:
		return null;
	
	file.store_var({
		"societyMgr" : Core.societyMgr.serialize(),
		"landablesMgr" : Core.landablesMgr.serialize(),
		"systemsMgr" : Core.systemsMgr.serialize(),
		"sectorsMgr" : Core.sectorsMgr.serialize(),
		"missionsMgr" : Core.missionsMgr.serialize(),
		"outsideWorldSim" : Core.outsideWorldSim.serialize(),
		"galacticTime" : galacticTime.serialize(),
	})

	return true;

func load_save():
	var file = File.new()
	if file.open('user://save_game.wdrr', File.READ) != OK:
		return null;

	var savedData = file.get_var();

	Core.societyMgr.deserialize(savedData["societyMgr"])
	Core.landablesMgr.deserialize(savedData["landablesMgr"])
	Core.systemsMgr.deserialize(savedData["systemsMgr"])
	Core.sectorsMgr.deserialize(savedData["sectorsMgr"])
	Core.missionsMgr.deserialize(savedData["missionsMgr"])
	Core.outsideWorldSim.deserialize(savedData["outsideWorldSim"])

	galacticTime = GalacticTime.new(0,0,0,0,0)
	galacticTime.deserialize(savedData["galacticTime"])
	
	for ID in Core.outsideWorldSim.data:
		var owner = Core.outsideWorldSim.data[ID].ownerChar
		if owner:
			owner = Core.societyMgr.get(owner)
			Core.outsideWorldSim.data[ID].ownerChar = owner
			owner.ship = Core.outsideWorldSim.data[ID]

	player = Core.societyMgr.get("player_character")
	playerShip = player.ship

	Core.load_scene()

	return true
