extends Node

const Sector = preload('Sector.gd')

var _sector;

func _enter_tree():
	_sector = Sector.new()
	self.add_child(_sector)
	_sector.init(Core.gameState.playerShip.currentSector)

	$"Layer-Widgets/ShipHoldView".init(Core.gameState.playerShip.hold)

	Core.outsideWorldSim.connect('bring_ship_in', self, 'bring_ship_in')
	pass

func _exit_tree():
	self.remove_child(_sector)
	_sector = null
	Core.outsideWorldSim.disconnect('bring_ship_in', self, 'bring_ship_in')

func _loaded_player_ship():
	get_node('Camera').followedShip = Core.gameState.playerShip

# Deals with popping ships in the player sector
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
				var delivered = false
				for l in landables:
					print(l)
					if !('jumpTo' in l):
						continue
					if l.jumpTo == ship.hyperNavigating.data.from:
						l.deliver(ship)
						delivered = true
						break
				# If this triggers, probably the target system has no 'reverse' jump point.
				# That's unsupported ATM.
				assert(delivered)
			Enums.HYPERNAVMETHOD.TELEPORTING:
				self.add_child(ship)
				ship.translation = Vector3(
					ship.hyperNavigating.data.position.x,
					0,
					ship.hyperNavigating.data.position.y
				)
	# Assume the ship has correct data.
	else:
		self.add_child(ship)
	if shipID == Core.gameState.playerShipID:
		_loaded_player_ship()

func _process(delta):
	pass

func _physics_process(delta):
	Core.gameState.galacticTime.add_time(delta*60*1000);
	Core.outsideWorldSim.advance(delta*60*1000);
	pass
