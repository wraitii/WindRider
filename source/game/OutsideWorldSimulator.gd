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

# array-per-system of ship IDs
# that will "unjump" on the next _process
var _shipsArrivingAt = {
}

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
	ship.connect('jumping', self, 'ship_jump')
	ship.connect('teleporting', self, 'ship_teleport')

func ship_jump(ship, to):
	var data = _ships[ship.ID].data;
	assert(data.currentSystem != null)
	data.lastSystem = data.currentSystem;
	data.currentSystem = null;
	data.hyperNavigating = HypernavigationData.hyperjump(to)
	_arriving_at(ship.ID, to)

func ship_teleport(ship, to, pos):
	var data = _ships[ship.ID].data;
	data.lastSystem = data.currentSystem; # may be null
	data.currentSystem = null;
	data.hyperNavigating = HypernavigationData.teleport(to, pos)
	_arriving_at(ship.ID, to)

func quit_hypernavigation(shipID):
	_ships[shipID].data.currentSystem = _ships[shipID].data.hyperNavigating.to;
	assert(_ships[shipID].data.currentSystem != null)
	_ships[shipID].data.hyperNavigating = null;

func _arriving_at(shipID, to):
	if !(to in _shipsArrivingAt):
		_shipsArrivingAt[to] = []
	_shipsArrivingAt[to].push_back(shipID)

func poll_all_arriving_at(at):
	if !(at in _shipsArrivingAt):
		return []
	var ret = _shipsArrivingAt[at]
	_shipsArrivingAt.erase(at)
	return ret;