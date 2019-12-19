extends Node

func _enter_tree():
	Core.remove_child(Core.runningSector)
	Core.runningSector.visible = true
	self.add_child(Core.runningSector)
	Core.runningSector.connect("loaded_player_ship", self, "_loaded_player_ship")

func _ready():
	_loaded_player_ship()

func _exit_tree():
	if Core.runningSector:
		self.remove_child(Core.runningSector)

func _loaded_player_ship():
	get_node('Camera').followedShip = Core.gameState.playerShip

func _process(delta):
	pass

func _physics_process(delta):
	Core.gameState.galacticTime.add_time(delta*60*1000);
	Core.outsideWorldSim.advance(delta*60*1000);
	pass
