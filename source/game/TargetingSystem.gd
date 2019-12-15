extends Node

### Targeting System
## Targets ships

var ownerShip = null;
var ownerComponent = null;

signal target(ID)
signal untarget(ID)

signal lost_target(ID)

# ship ID >> data
var targets = {};

class TargetingData:
	var targetID;
	
	func _init(t):
		targetID = t;

func init(c, s):
	ownerShip = s;
	ownerComponent = c;

# This cycles through all available targets
func pick_new_target(var first = false):
	var ships = get_tree().get_nodes_in_group('sector_ships')
	
	var ctarget = get_active_target()
	for ship in ships:
		if ship == ownerShip:
			continue
		if ship.ID in targets:
			continue
		if !first and ctarget and ctarget.ID >= ship.ID:
			continue
		target(ship.ID)
		return
	pick_new_target(true)

func get_active_target():
	if targets.size() == 0:
		return null;
	return Core.outsideWorldSim.ship(targets.values()[0].targetID)

func target(shipID):
	if targets.size() > 0:
		reset()
	_add_target(shipID)

func reset():
	for targetID in targets.keys():
		emit_signal('untarget', targetID)
	targets = {}

func _add_target(shipID):
	targets[shipID] = TargetingData.new(shipID)
	var ship = Core.outsideWorldSim.ship(shipID)
	ship.connect('tree_exiting', self, '_target_gone', [ship])
	emit_signal('target', shipID)

func _target_gone(node):
	if node.ID in targets:
		emit_signal('lost_target', node.ID)
		targets.erase(node.ID)
		emit_signal('untarget', node.ID)
