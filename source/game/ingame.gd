extends Node

export (String) var _system = null;

const System = preload('System.tscn')

func _ready():
	_system = Core.gameState.playerShip.currentSystem;
	
	var system = System.instance()	
	system.init(Core.galaxy.system(_system))
	self.add_child(system)
	
	self.add_child(Core.gameState.playerShip)

	get_node('Camera').followedShip = Core.gameState.playerShip
	get_node('VelocityRadar').set_follower(Core.gameState.playerShip)
	get_node('NavSystem').navSystem = Core.gameState.playerShip.navSystem

	pass

func _process(delta):
	pass

func _physics_process(state):
	pass
