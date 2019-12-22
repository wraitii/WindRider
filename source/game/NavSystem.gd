extends Node

signal navsystem_target_change()

# More stable targets
var navTargetsIDs = [];

class Target:
	enum TARGET_TYPE { JUMPZONE, LANDABLE, SECTOR, SYSTEM }
	var type;
	var ID;
	# Cached weak reference
	var nodeRef;
	# Cached waypoints -> each of these is a target itself.
	var waypoints = [];
	
	func _init(node):
		nodeRef = weakref(node)

		var Landable = load('res://source/game/Landable.gd')
		var JumpZone = load('res://source/game/JumpZone.gd')
		var Sector = load('res://source/game/Sector.gd')
		var SectorData = load('res://source/game/SectorData.gd')

		if node is JumpZone:
			type = TARGET_TYPE.JUMPZONE
			ID = node.jumpTo
			return
		elif node is Landable:
			type = TARGET_TYPE.LANDABLE
		elif node is Sector or node is SectorData:
			type = TARGET_TYPE.SECTOR
		else:
			type = TARGET_TYPE.SYSTEM
		ID = node.ID

var ship = null;

func _enter_tree():
	ship = get_parent();

func reset(send_signal = true):
	navTargetsIDs.clear()
	if send_signal:
		emit_signal('navsystem_target_change')

func set_target_node(node):
	reset(false)
	
	var tg = Target.new(node)
	
	# Step 1: Get the sector of the target
	
	# Step 2: Compute a sector-path to the target.
	if tg.type == Target.TARGET_TYPE.SYSTEM or tg.type == Target.TARGET_TYPE.SECTOR:
		compute_sector_path_to(ship.currentSector, tg)
	
	# Step 3: Compute a path to the first waypoint.
	var waypoint = _get_first_wpt(tg)
	if waypoint.type == Target.TARGET_TYPE.SECTOR:
		var jzs = get_tree().get_nodes_in_group("JumpZones")
		for jz in jzs:
			if jz.jumpTo == waypoint.ID:
				waypoint.waypoints.push_front(Target.new(jz))
				break
		assert(!waypoint.waypoints.empty())

	navTargetsIDs.append(tg)
	emit_signal('navsystem_target_change')

func compute_sector_path_to(from, target):
	assert(target.type == Target.TARGET_TYPE.SYSTEM or target.type == Target.TARGET_TYPE.SECTOR)
	var bestPath = null
	if target.type == Target.TARGET_TYPE.SYSTEM:
		var bestJ = 10000
		for sec in target.nodeRef.get_ref().sectors:
			var p = Core.sectorsMgr.astar.get_path(from, sec)
			if len(p) < bestJ:
				bestPath = p
				bestJ = len(p)
	else:
		bestPath = Core.sectorsMgr.astar.get_path(from, target.ID)
	# Remove current and target sectors from the list, add as waypoints.
	bestPath.pop_front()
	bestPath.pop_back()
	bestPath.invert()
	for wpt in bestPath:
		target.waypoints.push_front(Target.new(Core.sectorsMgr.get(wpt)))
	return target

func has_target():
	return len(navTargetsIDs) > 0

# Returns the first waypoint to the target (or the target if none)
func get_active_target():
	if !has_target():
		return null
	return _get_first_wpt(navTargetsIDs[0])

func _get_first_wpt(tg):
	if tg.waypoints.empty():
		return tg
	return _get_first_wpt(tg.waypoints[0])

# Always return the actual target, not waypoints, though these can be accessed.
func get_final_target():
	if !has_target():
		return null
	return navTargetsIDs[0]


func target_closest_nav_object():
	var landables = get_tree().get_nodes_in_group('Landables') + get_tree().get_nodes_in_group('JumpZones')
	var bestLandable = [null,null]
	for landable in landables:

		var dist = landable.position.distance_squared_to(ship.translation)
		if bestLandable[1] == null || dist <= bestLandable[1]:
			bestLandable[0] = landable;
			bestLandable[1] = dist;
	set_target_node(bestLandable[0])

