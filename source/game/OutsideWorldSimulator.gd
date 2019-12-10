extends Node

## Because of computational, programmer, and Godot limitations
## (can only run one instance of Bullet for example)
## The world outside the current sector cannot be played
## with the same level of detail.
## To keep continuity and make it feel alive,
## we thus rely on the OutsideWorldSimulator,
## whose job is to make the player think we are actually
## playing those outside sectors.

const Ship = preload('Ship.gd')

## This is also essentially the galaxy-wide ship manager
## because of that.

var _ships = {
}

#### Optimizations

# array-per-landable of ships navigating in a sector (not docked)
var _shipIDsInSector = {
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
	elif (ship.currentSector):
		if !(ship.currentSector in _shipIDsInSector):
			_shipIDsInSector[ship.currentSector] = []
		_shipIDsInSector[ship.currentSector].push_back(ship.ID)

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
	var sector = ship(shipID).currentSector
	
	if !(sector in _shipIDsInSector):
		_shipIDsInSector[sector] = []
	_shipIDsInSector[sector].push_back(shipID)

	if Core.gameState.playerShipID == shipID:
		Core.load_scene()
		# Bring in all ships navigating in this sector
		for shipID in _shipIDsInSector[sector]:
			emit_signal("bring_ship_in", shipID)

	elif Core.gameState.playerShip.currentSector == sector:
		emit_signal("bring_ship_in", shipID)

func ship_docked(shipID, at):
	assert(shipID in _ships)
	
	if !(at in _shipIDsDockedAt):
		_shipIDsDockedAt[at] = []
	_shipIDsDockedAt[at].push_back(shipID)

	if Core.landablesMgr.get(at).sectorID in _shipIDsInSector:
		if shipID in _shipIDsInSector[Core.landablesMgr.get(at).sectorID]:
			_shipIDsInSector[Core.landablesMgr.get(at).sectorID].erase(shipID)

	if Core.gameState.playerShipID == shipID:
		Core.load_scene()

func ship_jumped(shipID, from):
	assert(shipID in _ships)
	# May be null in case we teleport out of thin air
	if from != null:
		assert(from in _shipIDsInSector)
		_shipIDsInSector[from].erase(shipID)
		if _shipIDsInSector[from].empty():
			_shipIDsInSector.erase(from)
	
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
	if ship.dockedAt != null:
		_shipIDsDockedAt[ship.dockedAt].erase(ship.ID)
	else:
		_shipIDsInSector[ship.currentSector].erase(ship.ID)
	_ships.erase(ship.ID)

# All ships in the current sector would be lost when it unloads,
# so we need to save those we care about.
func sector_about_to_unload():
	if Core.gameState.currentScene == null:
		return

	for ship in Core.gameState.currentScene.get_children():
		if !(ship is Ship):
			continue
		ship.get_parent().remove_child(ship)
		# TODO: could be worth deleting those we don't care about

func advance(delta):
	if Core.gameState.playerShip == null:
		return
	var sys = Core.gameState.playerShip.currentSector
	if Core.gameState.playerShip.dockedAt != null:
		return
	for ship in _shipIDsInSector[sys]:
		if ship == Core.gameState.playerShip.ID:
			continue
		if ship(ship).AI == null:
			continue
		ship(ship).AI.do_ai()
