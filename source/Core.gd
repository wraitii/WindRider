extends Node
## Autoloaded at start, always present.

const Galaxy = preload('game/Galaxy.gd')
const ComponentDataMgr = preload('game/ComponentDataMgr.gd')
const ShipDataManager = preload('game/ShipDataManager.gd')
const LandableDataMgr = preload('game/LandableDataMgr.gd')

const GameStatus = preload('game/GameStatus.gd')
const OutsideWorldSim = preload('game/OutsideWorldSimulator.gd')

const InGame = preload('game/ingame.tscn')
const Docked = preload('game/Docked.tscn')

const Player = preload('game/Player.tscn')
const Ship = preload('game/Ship.tscn')

var player = null;
var galaxy = Galaxy.new()
var shipsData = ShipDataManager.new()
var componentsData = ComponentDataMgr.new()
var landablesData = LandableDataMgr.new()
var gameState = GameStatus.new()
var outsideWorldSim = OutsideWorldSim.new()

func startGame():
	gameState.currentSystem = 'Sol'
	gameState.playerShip = Ship.instance()
	gameState.playerShip.init('Cycles')
	gameState.playerShip.teleport('Sol', Vector2(100, 100))
	
	player = Player.instance()
	player.setCurrentShip(gameState.playerShip)
	get_node('/root').add_child(player)
	
	get_node('/root/MainMenu').queue_free()
	reload_scene()
	gameState.playerShip.global_translate(Vector3(0,0,0))

func reload_scene():
	if gameState.currentScene:
		gameState.currentScene.queue_free()
	
	var playerShipData = outsideWorldSim.ship(gameState.playerShip.ID);
	print(playerShipData.data.dockedAt)
	if playerShipData.data.dockedAt != null:
		gameState.currentScene = Docked.instance()
		gameState.currentScene.init(landablesData.get(playerShipData.data.dockedAt));
		get_node('/root').add_child(gameState.currentScene)
	else:
		gameState.currentScene = InGame.instance()
		get_node('/root').add_child(gameState.currentScene)
