extends Node

export (String) var _system = null;

const System = preload('System.tscn')

func _ready():
	_system = Core.gameState.currentSystem;

	var system = System.instance()	
	system.init(Core.galaxy.system(_system))
	self.add_child(system)
	
	bring_in_all()
	
	Core.outsideWorldSim.connect('bring_in', self, 'bring_in')
	
	get_node('Camera').followedShip = Core.gameState.playerShip
	get_node('VelocityRadar').set_follower(Core.gameState.playerShip)
	get_node('NavSystem').navSystem = Core.gameState.playerShip.navSystem

	pass

func bring_in_all():
	var ships = Core.outsideWorldSim.poll_all_arriving_at(_system);
	for shipID in ships:
		bring_in(shipID)
	
func bring_in(shipID):
	var ship = Core.outsideWorldSim.ship(shipID)
	if ship.data.dockedAt != null:
		var landables = get_tree().get_nodes_in_group('Landables')
		for l in landables:
			if l.data.name == ship.data.dockedAt
				l.deliver(ship.ship)
	assert(ship.data.hyperNavigating != null)
	match ship.data.hyperNavigating.method:
		Enums.HYPERNAVMETHOD.JUMPING:
			var landables = get_tree().get_nodes_in_group('Landables')
			for l in landables:
				if !('jumpTo' in l):
					continue
				if l.jumpTo == ship.data.lastSystem:
					l.deliver(ship.ship)
		Enums.HYPERNAVMETHOD.TELEPORTING:
			self.add_child(ship.ship)
			ship.ship.translation = Vector3(
				ship.data.hyperNavigating.data.position.x,
				0,
				ship.data.hyperNavigating.data.position.y
			)
			Core.outsideWorldSim.quit_hypernavigation(shipID);

func _process(delta):
	pass

func _physics_process(state):
	pass
