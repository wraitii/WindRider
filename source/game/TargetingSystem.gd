extends Node

### Targeting System
## Targets ships

var ownerShip = null;
var ownerComponent = null;

#### GUI signals
signal target(ID)
signal untarget(ID)

## Player / AI signal
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

func pick_new_target():
	var ships = get_tree().get_nodes_in_group('sector_ships')
	
	for ship in ships:
		if ship == ownerShip:
			continue
		if ship.ID in targets:
			continue
		target(ship.ID)

func get_active_target():
	if targets.size() == 0:
		return null;
	return Core.outsideWorldSim.ship(targets.values()[0].targetID)

func target(shipID):
	if targets.size() > 0:
		clear_targets()
	_add_target(shipID)

func clear_targets():
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
