extends Node

export (String) var _system = null;

func _ready():
	_system = Core.systemsMgr.get(Core.gameState.playerShip.currentSystem)
	self.add_child(_system)
	
	Core.outsideWorldSim.connect('bring_ship_in', self, 'bring_ship_in')
	pass

func _exit_tree():
	self.remove_child(_system)
	Core.outsideWorldSim.disconnect('bring_ship_in', self, 'bring_ship_in')

func _loaded_player_ship():
	get_node('Camera').followedShip = Core.gameState.playerShip

func bring_ship_in(shipID):
	var ship = Core.outsideWorldSim.ship(shipID)
	if ship.docking != null:
		assert(ship.docking.status == Enums.DOCKSTATUS.UNDOCKING)
		var landables = get_tree().get_nodes_in_group('Landables')
		for l in landables:
			if l.ID == ship.docking.dock:
				l.deliver(ship)
				break
	elif ship.hyperNavigating != null:
		match ship.hyperNavigating.method:
			Enums.HYPERNAVMETHOD.JUMPING:
				var landables = get_tree().get_nodes_in_group('JumpZones')
				for l in landables:
					print(l)
					if !('jumpTo' in l):
						continue
					if l.jumpTo == ship.hyperNavigating.data.from:
						l.deliver(ship)
						break
			Enums.HYPERNAVMETHOD.TELEPORTING:
				self.add_child(ship)
				ship.translation = Vector3(
					ship.hyperNavigating.data.position.x,
					0,
					ship.hyperNavigating.data.position.y
			)
	if shipID == Core.gameState.playerShipID:
		_loaded_player_ship()

func _process(delta):
	pass

func _physics_process(delta):
	Core.gameState.galacticTime.add_time(delta*60*1000);
	pass
