extends "res://source/lib/EntityMgr.gd"

## Because of computational and practical limitations
## The world outside the current sector shan't be played
## with the same level of detail.
## To keep continuity and make it feel alive,
## we thus rely on the OutsideWorldSimulator,
## whose job is to make the player think we are actually
## playing those outside sectors.
## This will get tricky.
## This is also essentially the galaxy-wide ship manager
## because of that (hence why it inherits EntityMgr)

const Ship = preload('Ship.tscn')

var counter = 0;
func _uid():
	var id = 'custom_' + str(counter) + '_' + str(OS.get_system_time_msecs());
	counter += 1
	assert(!(id in data))
	# We support creating up to 500K items in a single millisecond
	if counter > 500000:
		counter = 0
	return id

#### 'Indexes' for optimised access to ships.
# array-per-landable of ships navigating in a sector (_not_ including docked ships)
var _shipIDsInSector = {
}

# array-per-landable of ship IDs landed there
var _shipIDsDockedAt = {
}

signal bring_ship_in(ID)

# No resource path in this class, as we'll load ships from characters initially for now.
func _init().('Ships', ''):
	pass

func _instance(sd):
	var ship = Ship.instance();
	sd.ID = _uid();
	ship.init(sd);
	_setup_connections(ship)
	return ship;

func serialize():
	var ret = {}
	for sid in data:
		ret[sid] = data[sid].serialize()
	return ret

func deserialize(d):
	for id in d:
		var s = Ship.instance()
		s.deserialize(d[id])
		s.ID = id
		data[s.ID] = s
		_setup_connections(s)
		
		if s.dockedAt:
			Utils.safe_push(_shipIDsDockedAt, s.dockedAt, s.ID)
		elif s.currentSector:
			Utils.safe_push(_shipIDsInSector, s.currentSector, s.ID)

func _setup_connections(ship):
	ship.connect('will_dock', self, 'ship_will_dock')
	ship.connect('docked', self, 'ship_docked')
	ship.connect('will_undock', self, 'ship_will_undock')
	ship.connect('undocked', self, 'ship_undocked')

	ship.connect('jump_out', self, 'ship_jump_out')
	ship.connect('will_jump_in', self, 'ship_will_jump_in')
	ship.connect('jumped_in', self, 'ship_jumped_in')

	ship.connect('ship_death', self, 'ship_death')

# Explicitly named alias for get
func ship(ID):
	assert(ID in data)
	return get(ID);

func get_ships_in(sector):
	if sector in _shipIDsInSector:
		return _shipIDsInSector[sector]
	return []

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

func evaluate_ship_keeping(sector):
	if !(sector in _shipIDsInSector):
		return

	for ship in _shipIDsInSector[sector]:
		# sanity
		if ship == Core.gameState.playerShip.ID:
			continue
		destroy_ship(ship(ship))

################################################
################################################
## General ship-event handlers

# Called when a ship jumps out of a sector.
func ship_jump_out(ship):
	assert(ship.ID in data)
	
	# May be null in case we teleport out of thin air
	if ship.currentSector != null:
		Utils.full_erase(_shipIDsInSector, ship.currentSector, ship.ID)
	
	if ship == Core.gameState.playerShip:
		if ship.currentSector != null:
			evaluate_ship_keeping(ship.currentSector)
		Core.clear_sector()
		Core.unload_scene()
		# so here we would simulate time passing.
	
	# Deferred call for cleanup purposes and we don't really need instant effects.
	ship.call_deferred('_on_jump_in')

func ship_will_jump_in(ship):
	if ship == Core.gameState.playerShip:
		Core.setup_sector()
	_ship_appears(ship)

func ship_jumped_in(ship):
	if ship == Core.gameState.playerShip:
		Core.load_scene()

# Called right before a ship docks
func ship_will_dock(ship):
	assert(ship.ID in data)
	Utils.full_erase(_shipIDsInSector, ship.currentSector, ship.ID)

	if ship == Core.gameState.playerShip:
		Core.clear_sector()
		Core.unload_scene()

	ship._on_dock()

# Called once a ship has docked.
func ship_docked(ship):
	assert(ship.ID in data)
	var docked_at = ship.dockedAt
	
	Utils.safe_push(_shipIDsDockedAt, docked_at, ship.ID)

	if Core.gameState.playerShip == ship:
		Core.load_scene()

# Called right before a ship undocks
func ship_will_undock(ship):
	Utils.full_erase(_shipIDsDockedAt, ship.dockedAt, ship.ID)
	if ship == Core.gameState.playerShip:
		Core.unload_scene()
		Core.setup_sector()
	
	_ship_appears(ship)
	ship._on_undock()

# Called once a ship has undocked.
func ship_undocked(ship):	
	if Core.gameState.playerShip == ship:
		Core.load_scene()

func ship_death(ship):
	destroy_ship(ship)

## Called to bring in  a ship
func _ship_appears(ship):
	var sector = ship.currentSector
	
	Utils.safe_push(_shipIDsInSector, sector, ship.ID)

	if Core.runningSector.ID == sector:
		Core.runningSector.bring_ship_in(ship.ID)

# Removes a ship from the game cleanly.
func destroy_ship(ship):
	if ship.dockedAt != null:
		Utils.full_erase(_shipIDsDockedAt, ship.DockedAt, ship.ID)
	else:
		Utils.full_erase(_shipIDsInSector, ship.currentSector, ship.ID)
	data.erase(ship.ID)
	NodeHelpers.queue_delete(ship);
