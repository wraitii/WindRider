extends Node

# Autopilot modes. State Machine.
enum MODE { OFF, NAVTARGET, INTERCEPT }

const modeDescs = ['Off', 'Nav', 'Intercept']

var autopilotMode = MODE.OFF;

const Landable = preload('res://source/game/Landable.gd')
const Ship = preload('res://source/game/Ship.gd')

## Manual mode lets you thrust wherever you're pointing in 'realistic' Euclidian fashion.
## Autothrust just tries to get you to the target speed, and slows you down
## automagically without needing to turn around, though slower than by doing that.
enum DRIVING_MODE { AUTOTHRUST, MANUAL }
var drivingMode = DRIVING_MODE.AUTOTHRUST;
var targetSpeed = 0;

var ship = null;

# Node that the autopilot is currently considering, as weakref
var target_ref = null;

func _enter_tree():
	ship = get_parent();

func reset():
	set_mode(MODE.OFF)

func activate():
	if ship.targetingSystem.get_active_target() != null:
		if ship.navSystem.get_target() == null:
			set_mode(MODE.INTERCEPT)
			return
	elif ship.navSystem.get_target() != null:
		set_mode(MODE.NAVTARGET)
	else:
		set_mode(MODE.OFF)
		ship.emit_signal('add_chat_message', "Autopilot: nothing to do")

func set_mode(mode):
	if autopilotMode == MODE.OFF and mode != MODE.OFF:
		add_to_group('autopilot_running')
	elif autopilotMode != MODE.OFF and mode == MODE.OFF:
		remove_from_group('autopilot_running')
		target_ref = null
	autopilotMode = mode

func switch_driving_mode():
	drivingMode += 1
	if drivingMode >= len(DRIVING_MODE):
		drivingMode = DRIVING_MODE.AUTOTHRUST;

func autorailroad():
	if drivingMode == DRIVING_MODE.AUTOTHRUST or autopilotMode != MODE.OFF:
		ship.railroading = max(0, min(1, ship.linear_velocity.length() / (0.4 * ship.stat('max_speed')) - 0.1));
	else:
		ship.railroading *= 0.96

func autothrust():
	var commands = []
	
	if drivingMode == DRIVING_MODE.AUTOTHRUST or autopilotMode != MODE.OFF:
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

	# AI ships need this.
	if ship != Core.gameState.playerShip:
		commands += autothrust()
		autorailroad()

	if autopilotMode == MODE.INTERCEPT:
		commands += _intercept()
	elif autopilotMode == MODE.NAVTARGET:
		commands += _nav()

	return commands

func _intercept():
	var target = ship.targetingSystem.get_active_target();

	if !target:
		set_mode(MODE.OFF)
		ship.emit_signal('add_chat_message', 'Autopilot: target no longer valid.')
		return []
	
	target_ref = weakref(target)
	
	var distance = ship.translation.distance_to(target.translation)
	targetSpeed = min(1, (distance - 100) / 500)

	# Assume weapon speed is 450
	var speed = lerp(450, targetSpeed * ship.stat('max_speed'), min(max((distance - 300)/1000,0),1))
	return [[ship, ['follow_vector', [get_firing_vector(speed)]]]]

func _nav():
	var target = ship.navSystem.get_target()
	
	if !target:
		set_mode(MODE.OFF)
		ship.emit_signal('add_chat_message', 'Autopilot: target no longer valid.')
		return []
	
	target_ref = weakref(target)
	targetSpeed = min(1, (target.translation - ship.translation).length_squared() / (400*400))

	return [[ship, 'follow_vector', [get_interception_vector()]]]

func update_target():
	var target
	if autopilotMode == MODE.INTERCEPT:
		target = ship.targetingSystem.get_active_target()
		if !target:
			return
	elif autopilotMode == MODE.NAVTARGET:
		target = ship.navSystem.get_target()
		if !target:
			return
	else:
		if ship.targetingSystem.get_active_target():
			target = ship.targetingSystem.get_active_target()
		else:
			target = ship.navSystem.get_target()
	target_ref = weakref(target)

func has_target():
	return target_ref.get_ref() != null

func get_target():
	return target_ref.get_ref()

func get_target_position():
	if !has_target():
		return null
	return get_target().translation

func get_firing_vector(speed = 500):
	if !has_target():
		return null
	if !(get_target() is RigidBody):
		return null
	
	return Intercept.simple_intercept(ship, get_target(), speed)[0]

func get_interception_vector(speed = null):
	if !has_target():
		return null
	
	var target = get_target()
	if !target.translation:
		return null
	
	if speed == null:
		speed = ship.stat('max_speed') * targetSpeed
	
	if target is RigidBody:
		return Intercept.simple_intercept(ship, target, speed)[0]
	else:
		return (target - ship.translation).normalized()
