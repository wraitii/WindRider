extends Node
## Autoloaded at start, always present.

const DataMgr = preload('lib/DataMgr.gd')

const SocietyMgr = preload('game/mgr/SocietyMgr.gd')
const SystemsMgr = preload('game/mgr/SystemsMgr.gd')
const SectorsMgr = preload('game/mgr/SectorsMgr.gd')
const LandableMgr = preload('game/mgr/LandableMgr.gd')
const MissionsMgr = preload('game/mgr/MissionsMgr.gd')
const OutsideWorldSim = preload('game/OutsideWorldSimulator.gd')

const DamageMgr = preload('game/DamageMgr.gd')

const GalacticTime = preload('game/GalacticTime.gd')
const GameStatus = preload('game/GameStatus.gd')

const InGame = preload('game/ingame.tscn')
const Docked = preload('game/Docked.tscn')

const Character = preload('game/Character.tscn')
const Ship = preload('game/Ship.tscn')

var dataMgr = DataMgr.new();

var societyMgr = SocietyMgr.new()
var systemsMgr = SystemsMgr.new()
var sectorsMgr = SectorsMgr.new()
var landablesMgr = LandableMgr.new()
var missionsMgr = MissionsMgr.new()
var outsideWorldSim = OutsideWorldSim.new()
var damageMgr = DamageMgr.new()

var gameState;
var runningSector = null;

func _on_new_game():
	NodeHelpers.queue_delete(get_node('/root/MainMenu'))
	gameState = GameStatus.new()
	gameState.create_new_game()

func _onload_saved_game():
	NodeHelpers.queue_delete(get_node('/root/MainMenu'))
	gameState = GameStatus.new();
	gameState.load_save();

func unload_scene():
	## May happen at the Start
	if gameState.currentScene == null:
		return
	NodeHelpers.queue_delete(gameState.currentScene)

func load_scene(scene = null):
	if scene == null:
		if gameState.playerShip.dockedAt != null:
			gameState.currentScene = Docked.instance()
			#gameState.currentScene.init(landablesMgr.get(gameState.playerShip.dockedAt));
		else:
			gameState.currentScene = InGame.instance()
			#gameState.currentScene.init(runningSector)
	else:
		gameState.currentScene = scene
	get_node('/root').add_child(gameState.currentScene)

const Sector = preload('game/Sector.tscn')

func clear_sector():
	assert(runningSector)
	runningSector.clear()
	NodeHelpers.queue_delete(runningSector)
	runningSector = null

func setup_sector():
	var sector_to_load = Core.gameState.playerShip.currentSector
	assert(sector_to_load)
	assert(!runningSector)
	runningSector = Sector.instance()
	runningSector.visible = false
	add_child(runningSector)
	runningSector.init(sector_to_load)

	# Create new ships in this sector, fetch existing ships.
	runningSector.generate_activity()
