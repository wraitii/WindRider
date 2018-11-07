extends Node
## Autoloaded at start, always present.

const Galaxy = preload('game/Galaxy.gd')
const GameStatus = preload('game/GameStatus.gd')
const InGame = preload('game/ingame.tscn')

const Ship = preload('game/Ship.tscn')

var galaxy = Galaxy.new()

var gameState = GameStatus.new()

func startGame():
	gameState.playerShip = Ship.instance()
	get_node('/root/MainMenu').queue_free()
	jump('Sol')
	gameState.playerShip.global_translate(Vector3(0,0,0))

func jump(to):
	var inGame = get_node('/root/InGameRoot')
	get_node('/root/').print_tree()
	if inGame:
		gameState.playerShip.get_parent().remove_child(gameState.playerShip)
		inGame.queue_free()
	
	gameState.playerShip.currentSystem = to
	var newGame = InGame.instance()
	get_node('/root').add_child(newGame)
	get_node('/root/').print_tree()
