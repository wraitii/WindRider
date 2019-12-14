extends Node

signal navsystem_target_change()

# Autopilot modes. State Machine.
enum MODE { OFF, MOVE }

var autopilotMode = MODE.OFF;

## Manual mode lets you thrust wherever you're pointing in 'realistic' Euclidian fashion.
## Autothrust just tries to get you to the target speed, and slows you down
## automagically without needing to turn around, though slower than by doing that.
enum DRIVING_MODE { AUTOTHRUST, MANUAL }
var drivingMode = DRIVING_MODE.AUTOTHRUST;
var targetSpeed = 0;

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
	remove_from_group('autopilot_running')
	

func reset(send_signal = true):
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
	
	var target = get_target().nodeRef.get_ref()
	
	# TODO: Compute a path to the next target.
	if target == null:
		return null

	if !'translation' in target:
		if 'position' in target:
			return target.position
		
	return target.translation

func target_closest_nav_object():
	var landables = get_tree().get_nodes_in_group('Landables') + get_tree().get_nodes_in_group('JumpZones')
	var bestLandable = [null,null]
	for landable in landables:

		var dist = landable.position.distance_squared_to(ship.translation)
		if bestLandable[1] == null || dist <= bestLandable[1]:
			bestLandable[0] = landable;
			bestLandable[1] = dist;
	set_target_node(bestLandable[0])

func set_mode(mode):
	if autopilotMode == MODE.OFF and mode != MODE.OFF:
		add_to_group('autopilot_running')
	elif autopilotMode != MODE.OFF and mode == MODE.OFF:
		remove_from_group('autopilot_running')
	autopilotMode = mode

func switch_driving_mode():
	drivingMode += 1
	if drivingMode >= len(DRIVING_MODE):
		drivingMode = DRIVING_MODE.AUTOTHRUST;

func autothrust():
	var ship = get_parent()
	assert(ship)
	var commands = []
	
	if drivingMode == DRIVING_MODE.AUTOTHRUST:
		var speed = ship.linear_velocity.length_squared();
		var delta = abs(speed - targetSpeed * ship.stat('max_speed') * ship.stat('max_speed'))
		if delta > 0.1:
			if speed < targetSpeed * ship.stat('max_speed') * ship.stat('max_speed'):
				commands.append([ship, 'thrust', max(1, delta)])
			elif speed > targetSpeed * ship.stat('max_speed') * ship.stat('max_speed'):
				commands.append([ship, 'reverse_thrust', max(1, delta)])
	return commands

func get_commands(delta):		
	var commands = []

	if autopilotMode == MODE.OFF:
		assert(!is_in_group('autopilot_running'))
		return commands

	var ship = get_parent()
	assert(ship)

	
	var tg = get_next_waypoint_position()
	if tg == null:
		return commands
	
	commands.append([ship, 'aim_towards_target'])
	return commands
