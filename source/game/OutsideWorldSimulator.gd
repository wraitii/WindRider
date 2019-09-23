extends Node

## Because of computational, programmer, and Godot limitations
## (can only run one instance of Bullet for example)
## The world outside the current system cannot be played
## with the same level of detail.
## To keep continuity and make it feel alive,
## we thus rely on the OutsideWorldSimulator,
## whose job is to make the player think we are actually
## playing those outside systems.

const Ship = preload('Ship.gd')

## This is also essentially the galaxy-wide ship manager
## because of that.

var _ships = {
}

#### Optimizations

# array-per-landable of ships navigating in a system (not docked)
var _shipIDsInSystem = {
}

# array-per-landable of ship IDs landed there
var _shipIDsDockedAt = {
}

signal bring_ship_in(ID)

func get_ships_to_save():
	var ret = []
	for ship in _ships.values():
		#if ship == Core.gameState.playerShip:
		ret.push_back(ship);
	return ret;

func deserialize_ship(ship):
	_ships[ship.ID] = ship
	if ids <= ship.ID:
		ids = ship.ID + 1;

	ship.connect('docked', self, 'ship_docked')
	ship.connect('undocked', self, 'ship_undocked')
	ship.connect('jumped', self, 'ship_jumped')
	ship.connect('unjumped', self, 'ship_unjumped')
	ship.connect('ship_death', self, 'ship_death')
	
	if (ship.dockedAt):
		if !(ship.dockedAt in _shipIDsDockedAt):
			_shipIDsDockedAt[ship.dockedAt] = []
		_shipIDsDockedAt[ship.dockedAt].push_back(ship.ID)
	elif (ship.currentSystem):
		if !(ship.currentSystem in _shipIDsInSystem):
			_shipIDsInSystem[ship.currentSystem] = []
		_shipIDsInSystem[ship.currentSystem].push_back(ship.ID)

var ids = 0;
	
func ship(ID):
	assert(ID in _ships)
	return _ships[ID];
	
func assign_id(ship):
	ship.ID = ids;
	ids += 1;
	_ships[ship.ID] = ship

	ship.connect('docked', self, 'ship_docked')
	ship.connect('undocked', self, 'ship_undocked')
	ship.connect('jumped', self, 'ship_jumped')
	ship.connect('unjumped', self, 'ship_unjumped')
	ship.connect('ship_death', self, 'ship_death')

func _ship_appears(shipID):
	var system = ship(shipID).currentSystem
	
	if !(system in _shipIDsInSystem):
		_shipIDsInSystem[system] = []
	_shipIDsInSystem[system].push_back(shipID)

	if Core.gameState.playerShipID == shipID:
		Core.load_scene()
		# Bring in all ships navigating in this system
		for shipID in _shipIDsInSystem[system]:
			emit_signal("bring_ship_in", shipID)

	elif Core.gameState.playerShip.currentSystem == system:
		emit_signal("bring_ship_in", shipID)

func ship_docked(shipID, at):
	assert(shipID in _ships)
	
	if !(at in _shipIDsDockedAt):
		_shipIDsDockedAt[at] = []
	_shipIDsDockedAt[at].push_back(shipID)

	if Core.landablesMgr.get(at).system.ID in _shipIDsInSystem:
		if shipID in _shipIDsInSystem[Core.landablesMgr.get(at).system.ID]:
			_shipIDsInSystem[Core.landablesMgr.get(at).system.ID].erase(shipID)

	if Core.gameState.playerShipID == shipID:
		Core.load_scene()

func ship_jumped(shipID, from):
	assert(shipID in _ships)
	# May be null in case we teleport out of thin air
	if from != null:
		assert(from in _shipIDsInSystem)
		_shipIDsInSystem[from].erase(shipID)
		if _shipIDsInSystem[from].empty():
			_shipIDsInSystem.erase(from)
	
	var ship = ship(shipID);
	if ship.hyperNavigating.method == Enums.HYPERNAVMETHOD.TELEPORTING:
		ship._do_unjump()
		return;
	
	if shipID == Core.gameState.playerShipID:
		# so here we would simulate time passing.
		ship(shipID)._do_unjump()

func ship_undocked(shipID, at):
	assert(shipID in _ships)
	assert(at in _shipIDsDockedAt)
	_shipIDsDockedAt[at].erase(shipID)
	if _shipIDsDockedAt[at].empty():
		_shipIDsDockedAt.erase(at)
	
	_ship_appears(shipID)

func ship_unjumped(shipID, into):
	assert(shipID in _ships)
	_ship_appears(shipID)

func ship_death(ship):
	print(ship)
	if ship.dockedAt != null:
		_shipIDsDockedAt[ship.dockedAt].erase(ship.ID)
	else:
		_shipIDsInSystem[ship.currentSystem].erase(ship.ID)
	_ships.erase(ship.ID)

# All ships in the current system would be lost when it unloads,
# so we need to save those we care about.
func system_about_to_unload():
	for ship in Core.gameState.currentScene.get_children():
		if !(ship is Ship):
			continue
		ship.get_parent().remove_child(ship)
		# TODO: could be worth deleting those we don't care about

func advance(delta):
	var sys = Core.gameState.playerShip.currentSystem
	if Core.gameState.playerShip.dockedAt != null:
		return
	for ship in _shipIDsInSystem[sys]:
		if ship == Core.gameState.playerShip.ID:
			continue
		# TODO : Ship AI
