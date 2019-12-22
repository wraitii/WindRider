extends Spatial

const Star = preload('Star.tscn')
const JumpZone = preload('JumpZone.tscn')
const Landable = preload('Landable.gd')
const Ship = preload('Ship.gd')

var ID;

# Sent when the player ship is brought in/out
signal loaded_player_ship()
signal unloaded_player_ship()

func init(sectorID):
	ID = sectorID;
	var sectorData = Core.sectorsMgr.get(ID)
	_parse_stars(sectorData)
	_parse_landables(sectorData)
	_parse_jump_zones(sectorData)
	return self

func clear():
	for c in get_children():
		if c is Landable:
			# Since for now I'm fetching landables directly from the mgr, I have to unparent them.
			remove_child(c)
		if c is Ship:
			# Detach the ships because this is getting destroyed along with children,
			# but the outside world manager might want some ships to stay alive.
			remove_child(c)

# Called by the world manager when the player jumps in a system.
# The role of this function is to load the sector with ships
# To make it look like we are simulating stuff properly.

const Character = preload('Character.tscn')

func generate_activity():
	var ships_already_there = Core.outsideWorldSim.get_ships_in(ID)
	for shipID in ships_already_there:
		bring_ship_in(shipID)

	var activity = Core.sectorsMgr.get(ID)['activity']
	
	var l = len(ships_already_there)
	for i in range(ceil(rand_range(activity-5-l,activity+5-l))):
		var shipType = 'Cycles'
		if randi() % 2 == 1:
			shipType = 'Manta'
		var ship = Core.outsideWorldSim.create_resource({'model': shipType})
		ship.teleport(ID, Vector3((randf()-0.5)*500, (randf()-0.5)*500, (randf()-0.5)*500))

func bring_ship_in(shipID):
	var ship = Core.outsideWorldSim.ship(shipID)

	_bring_ship_in(ship)

	self.add_child(ship)
	ship.add_to_group('sector_ships')

	if ship == Core.gameState.playerShip:
		emit_signal("loaded_player_ship")

func _bring_ship_in(ship):
	if ship.dockingProcess != null:
		assert(ship.dockingProcess.status == Enums.DOCKSTATUS.UNDOCKING)
		var landables = get_tree().get_nodes_in_group('Landables')
		for l in landables:
			if l.ID == ship.dockingProcess.dock:
				l.deliver(ship)
				return
			# if the game arrives here, something is wrong and we should crash.
			assert(0)

	if ship.hyperNavigating != null:
		match ship.hyperNavigating.method:
			Enums.HYPERNAVMETHOD.JUMPING:
				var landables = get_tree().get_nodes_in_group('JumpZones')
				var delivered = false
				for l in landables:
					if !('jumpTo' in l):
						continue
					if l.jumpTo == ship.hyperNavigating.data.from:
						l.deliver(ship)
						delivered = true
						return
				# If this triggers, probably the target system has no 'reverse' jump point.
				# That's unsupported ATM.
				assert(delivered)
			Enums.HYPERNAVMETHOD.TELEPORTING:
				ship.translation = ship.hyperNavigating.data.position
		return
	
	# Otherwise, the ship was already in the sector.
	# For now we'll just give these a random position
	ship.translation = Vector3((randf()-0.5)*5000, (randf()-0.5)*5000, (randf()-0.5)*5000)

########################################
########################################
## Load sector objects

func _parse_stars(sectorData):
	var systemData = Core.systemsMgr.get(sectorData['system'])
	if !("stars" in systemData):
		return

	for starDef in systemData['stars']:
		var star = Star.instance()
		add_child(star)
		var pos = (A2V._3(starDef['position']) - sectorData.position) * 100
		star.translate(pos)
		star.scale_object_local(Vector3(100,100,100))
		star.lightDir = -pos

func _parse_landables(sysData):
	if !("landables" in sysData):
		return

	for landableID in sysData['landables']:
		var landable = Core.landablesMgr.get(landableID)
		landable.sectorID = ID;
		self.add_child(landable)

func _parse_jump_zones(sysData):
	if !("jump_zones" in sysData):
		return

	for jsd in sysData['jump_zones']:
		var jumpZone = JumpZone.instance()
		jumpZone.init(ID, jsd)
		self.add_child(jumpZone)

