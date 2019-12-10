extends Node
## Autoloaded at start, always present.

const DataMgr = preload('lib/DataMgr.gd')

const SocietyMgr = preload('game/mgr/SocietyMgr.gd')
const SystemsMgr = preload('game/mgr/SystemsMgr.gd')
const SectorsMgr = preload('game/mgr/SectorsMgr.gd')
const LandableMgr = preload('game/mgr/LandableMgr.gd')
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
var outsideWorldSim = OutsideWorldSim.new()

var gameState;
var damageMgr = DamageMgr.new()

func create_new_game():
	societyMgr.populate()
	landablesMgr.populate()
	systemsMgr.populate()
	sectorsMgr.populate()
	
	## TODO: if I get an outfitMgr or something this should be replaced
	societyMgr.assign_outfits()
	
	NodeHelpers.queue_delete(get_node('/root/MainMenu'))
	
	gameState = GameStatus.new()
	
	gameState.galacticTime = GalacticTime.new(3065, 04, 12, 13, 48)
	
	gameState.player = Character.instance()
	gameState.player.credits = 10000;
	
	var playerShip = Ship.instance()
	playerShip = Ship.instance()
	playerShip.init('Cycles')
	gameState.player.ship = playerShip
	
	get_node('/root').add_child(gameState.player)

	gameState.playerShip.teleport('Kerguelen', Vector2(-2000, 0))

	for i in range(10):
		var otherShip = Ship.instance()
		otherShip.init('Cycles_slow')
		otherShip.teleport('Kerguelen', Vector2((randf()-0.5)*50, (randf()-0.5)*50))
	gameState.save_game();

func load_saved_game():
	societyMgr.populate()
	landablesMgr.populate()
	systemsMgr.populate()
	sectorsMgr.populate()
	
	## TODO: if I get an outfitMgr or something this should be replaced
	societyMgr.assign_outfits()

	NodeHelpers.queue_delete(get_node('/root/MainMenu'))
	gameState = GameStatus.new();
	gameState.load_save(get_node('/root'));
	load_scene();

func unload_scene():
	## May happen at the Start
	if gameState.currentScene == null:
		return

	if gameState.playerShip != null && gameState.playerShip.is_inside_tree():
		gameState.playerShip.get_parent().remove_child(gameState.playerShip)
	NodeHelpers.queue_delete(gameState.currentScene)

func load_scene():
	if gameState.playerShip.dockedAt != null:
		gameState.currentScene = Docked.instance()
		gameState.currentScene.init(landablesMgr.get(gameState.playerShip.dockedAt));
		get_node('/root').add_child(gameState.currentScene)
	else:
		gameState.currentScene = InGame.instance()
		get_node('/root').add_child(gameState.currentScene)
