extends Node

signal navsystem_target_change()

# Achtung: this is a reference to the actual node
var targetNode = null;

# More stable targets
var navTargetsIDs = [];

class Target:
	enum TARGET_TYPE { JUMPZONE, LANDABLE, SECTOR, SYSTEM }
	var type;
	var ID;
	# Cached weak reference
	var nodeRef;
	# Cached waypoints
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

func _exit_tree():
	targetNode = null;

func reset(send_signal = true):
	targetNode = null;
	navTargetsIDs.clear()
	if send_signal:
		emit_signal('navsystem_target_change')

func set_target_node(node):
	reset(false)
	navTargetsIDs.append(Target.new(node))
	emit_signal('navsystem_target_change')

func has_target():
	return len(navTargetsIDs) > 0

func get_target():
	if !has_target():
		return null
	return navTargetsIDs[0]

func get_next_waypoint_position():
	if !has_target():
		return null
	
	# TODO: Compute a path to the next target.
	if get_target().nodeRef.get_ref() == null:
		return null

	if !'translation' in get_target().nodeRef.get_ref():
		return null
		
	return get_target().nodeRef.get_ref().translation

func target_closest_nav_object():
	var landables = get_tree().get_nodes_in_group('Landables') + get_tree().get_nodes_in_group('JumpZones')
	var bestLandable = [null,null]
	for landable in landables:

		var dist = landable.position.distance_squared_to(ship.translation)
		if bestLandable[1] == null || dist <= bestLandable[1]:
			bestLandable[0] = landable;
			bestLandable[1] = dist;
	targetNode = bestLandable[0]
	set_target_node(targetNode)
	
