extends Node
## Autoloaded at start, always present.

const Galaxy = preload('game/Galaxy.gd')
const ComponentDataMgr = preload('game/ComponentDataMgr.gd')
const ShipDataManager = preload('game/ShipDataManager.gd')
const LandableDataMgr = preload('game/LandableDataMgr.gd')
const ProjectileDataMgr = preload('game/ProjectileDataMgr.gd')

const GameStatus = preload('game/GameStatus.gd')
const OutsideWorldSim = preload('game/OutsideWorldSimulator.gd')
const DamageMgr = preload('game/DamageMgr.gd')

const InGame = preload('game/ingame.tscn')
const Docked = preload('game/Docked.tscn')

const Player = preload('game/Player.tscn')
const Ship = preload('game/Ship.tscn')

var galaxy = Galaxy.new()
var shipsData = ShipDataManager.new()
var componentsData = ComponentDataMgr.new()
var projectilesData = ProjectileDataMgr.new()
var landablesData = LandableDataMgr.new()
var gameState = GameStatus.new()
var outsideWorldSim = OutsideWorldSim.new()
var damageMgr = DamageMgr.new()

func startGame():
	NodeHelpers.queue_delete(get_node('/root/MainMenu'))
	
	gameState.player = Player.instance()
	var playerShip = Ship.instance()
	playerShip = Ship.instance()
	playerShip.init('Cycles')
	gameState.player.ship = playerShip
	
	get_node('/root').add_child(gameState.player)

	gameState.playerShip.teleport('Sol', Vector2(20, 0))

	var otherShip = Ship.instance()
	otherShip.init('Cycles')
	otherShip.teleport('Sol', Vector2(0, -50))

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
		gameState.currentScene.init(landablesData.get(gameState.playerShip.dockedAt));
		get_node('/root').add_child(gameState.currentScene)
	else:
		gameState.currentScene = InGame.instance()
		get_node('/root').add_child(gameState.currentScene)
