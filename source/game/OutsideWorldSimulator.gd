extends Node

## Because of computational, programmer, and Godot limitations
## (can only run one instance of Bullet for example)
## The world outside the current system cannot be played
## with the same level of detail.
## To keep continuity and make it feel alive,
## we thus rely on the OutsideWorldSimulator,
## whose job is to make the player think we are actually
## playing those outside systems.

## This is also essentially the galaxy-wide ship manager
## because of that.

var _ships = {
}

# array-per-landable of ships navigating in system
var _shipIDsInSystem = {
}

# array-per-landable of ship IDs landed there
var _shipIDsDockedAt = {
}

signal bring_in(obj)

var ids = 0;

class HypernavigationData:
	var method = null;
	var to = null;
	var data = null;
	
	func _init(m, t, d = {}):
		to = t
		method = m
		data = d
	
	static func hyperjump(to):
		return HypernavigationData.new(
			Enums.HYPERNAVMETHOD.JUMPING,
			to
		)
	static func teleport(to, pos):
		return HypernavigationData.new(
			Enums.HYPERNAVMETHOD.TELEPORTING,
			to,
			{ 'position': pos }
		)

class _shipsimData:
	var lastSystem = null;
	var currentSystem = null;
	var hyperNavigating = null;
	var dockedAt = null;

func ship(ID):
	assert(ID in _ships)
	return _ships[ID];
	
func assign_id(ship):
	ship.ID = ids;
	ids += 1;
	_ships[ship.ID] = {
		'ship': ship,
		'data': _shipsimData.new()
	};
	ship.connect('docking', self, 'ship_dock')
	ship.connect('undocking', self, 'ship_undock')
	ship.connect('jumping', self, 'ship_jump')
	ship.connect('teleporting', self, 'ship_teleport')

func ship_dock(ship, at):
	var data = _ships[ship.ID].data;
	assert(data.hyperNavigating == null)
	_docked_at(ship.ID, at)
	data.dockedAt = at;
	if ship == Core.gameState.playerShip:
		Core.reload_scene();

func ship_undock(ship):
	var data = _ships[ship.ID].data;
	assert(data.hyperNavigating == null)
	assert(data.dockedAt != null)
	assert(_shipIDsDockedAt[data.dockedAt].has(ship.ID))
	_shipIDsDockedAt[data.dockedAt].erase(ship.ID)
	if ship == Core.gameState.playerShip:
		Core.reload_scene();
	emit_signal('bring_in', ship)

func ship_jump(ship, to):
	var data = _ships[ship.ID].data;
	assert(data.currentSystem != null)
	data.lastSystem = data.currentSystem;
	data.currentSystem = null;
	_shipIDsInSystem[data.lastSystem].erase(ship.ID)
	data.hyperNavigating = HypernavigationData.hyperjump(to)
	if ship == Core.gameState.playerShip:
		Core.gameState.currentSystem = to
		Core.reload_scene();
	emit_signal('bring_in', ship)

func ship_teleport(ship, to, pos):
	var data = _ships[ship.ID].data;
	data.lastSystem = data.currentSystem; # may be null
	data.currentSystem = null;
	_shipIDsInSystem[data.lastSystem].erase(ship.ID)
	data.hyperNavigating = HypernavigationData.teleport(to, pos)
	emit_signal('bring_in', ship)

func quit_hypernavigation(shipID):
	_ships[shipID].data.currentSystem = _ships[shipID].data.hyperNavigating.to;
	assert(_ships[shipID].data.currentSystem != null)
	_ships[shipID].data.hyperNavigating = null;

func _docked_at(shipID, at):
	if !(at in _shipIDsDockedAt):
		_shipIDsDockedAt[at] = []
	_shipIDsDockedAt[at].push_back(shipID)

func _add_to_system(shipID, sys):
	if !(sys in _shipIDsInSystem):
		_shipIDsInSystem[sys] = []
	_shipIDsInSystem[sys].push_back(shipID)
