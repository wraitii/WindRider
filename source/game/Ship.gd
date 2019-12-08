extends RigidBody

# intended for the human player only
signal add_chat_message(message)

signal ship_death(ship)

const NavSystem = preload('res://source/game/NavSystem.gd')
const Docking = preload('res://source/game/comms/Docking.gd')
const Graphics = preload('res://source/graphics/Ship.tscn')

var ID;

var dockingProcedure = null

var data;

# subsystems shorthand
var AI;
var navSystem;
var weaponsSystem;
var targetingSystem;
var shipStats;

# Navigation
var lastSector = null;
var currentSector = null;
var dockedAt = null;
var hyperNavigating = null;
var docking = null;

## Manual mode means thrust = boosters.
## Autothrust and railroading is probably what you want,
## but a quick bout of no-railroad manual burst mode can be fun.
enum DRIVING_MODE { AUTOTHRUST, MANUAL }
var driving_mode = DRIVING_MODE.AUTOTHRUST;
var target_speed = 0;
# How 'railroaded' the ship's inertia is currently being.
# Runs between 0 (realistic behaviour) and 1 (star wars)
var railroading = 0.0;

## Ship caracteristics
var hyperfuel = null
var energy = null setget set_energy, get_energy;
var shields = null setget set_shields, get_shields;
var armour = null setget set_armour, get_armour;

func stat(stat):
	return shipStats.get(stat)

func _init():
	set_linear_damp(0);
	set_angular_damp(0.98);
	add_to_group('Ships', true)
	pass

func init(shipType):
	Core.outsideWorldSim.assign_id(self);
	navSystem = get_node('NavSystem');
	weaponsSystem = get_node('WeaponsSystem');
	targetingSystem = get_node('TargetingSystem');
	shipStats = get_node('ShipStats');
	AI = get_node('AI');
	
	data = Core.dataMgr.get('ships/' + shipType)
	shipStats.init(data)
	targetingSystem.init(null, self);
	
	shields = stat('max_shields')
	armour = stat('max_armour')
	energy = stat('max_energy')
	hyperfuel = stat('max_hyperfuel')

	get_node('ShipGraphics').init(data)
	pass

func serialize():
	var ret = {}
	ret.ID = ID
	ret.data = data
	ret.shields = shields
	ret.armour = armour
	ret.energy = energy
	ret.hyperfuel = hyperfuel
	ret.lastSector = lastSector
	ret.currentSector = currentSector
	ret.dockedAt = dockedAt
	ret.hyperNavigating = hyperNavigating
	ret.docking = docking
	
	return ret;

func deserialize(ret):
	ID = ret.ID
	data = ret.data
	
	lastSector = ret.lastSector
	currentSector = ret.currentSector
	dockedAt = ret.dockedAt
	hyperNavigating = ret.hyperNavigating
	docking = ret.docking
	
	navSystem = get_node('NavSystem');
	weaponsSystem = get_node('WeaponsSystem');
	targetingSystem = get_node('TargetingSystem');
	shipStats = get_node('ShipStats')
	
	shipStats.init(data)
	targetingSystem.init(null, self);
	get_node('ShipGraphics').init(data)
	
	shields = ret.shields
	armour = ret.armour
	energy = ret.energy
	hyperfuel = ret.hyperfuel
	
func _process(delta):
	pass

func _physics_process(delta):
	energy += stat('energy_gen') * delta
	if energy > stat('max_energy'):
		energy = stat('max_energy')
	
	if driving_mode == DRIVING_MODE.AUTOTHRUST:
		railroading = max(0, min(1, linear_velocity.length() / (0.4 * stat('max_speed')) - 0.1));
	else:
		railroading *= 0.96

func switch_rr_mode():
	driving_mode += 1
	if driving_mode >= len(DRIVING_MODE):
		driving_mode = DRIVING_MODE.AUTOTHRUST;


##############################
##############################
## Physics

func _integrate_forces(state):
	var speed = state.linear_velocity.length_squared();
	var dir = state.linear_velocity.normalized();
	#if speed > 0:
	#	state.linear_velocity = state.linear_velocity - dir * 0.05;
	if speed > stat('max_speed') * stat('max_speed'):
		state.linear_velocity = dir * stat('max_speed')
	
	if driving_mode == DRIVING_MODE.AUTOTHRUST:
		if speed < target_speed * target_speed:
			state.add_central_force(_rel_vec(Vector3(0,0,-1), safe_stat('acceleration', 1.0)))
		elif speed > target_speed * target_speed:
			state.add_central_force(_rel_vec(Vector3(0,0,1), safe_stat('acceleration', 0.2)))

	# Railroading (orient velocity wherever the ship is pointing)
	var velo_local = get_transform().basis.inverse() * state.linear_velocity
	var rot = Quat(Transform().looking_at(state.linear_velocity, Vector3(0,1,0)).basis)
	rot = rot.slerp(get_transform().basis, 0.1 * railroading)
	state.linear_velocity = rot.xform(Vector3(0,0,-1)) * state.linear_velocity.length()


func _rel_vec(vec, power):
	var transform = get_transform()
	var pushDir = transform.xform(vec) - translation
	return pushDir * power

func safe_stat(stat, percent):
	return shipStats.get(stat) * max(0, min(1, percent))

func thrust(percent = 1.0):
	if driving_mode == DRIVING_MODE.AUTOTHRUST:
		target_speed = min(stat('max_speed'), target_speed + 1)
	else:
		add_central_force(_rel_vec(Vector3(0,0,-1), safe_stat('acceleration', percent)))

func rotate_up(percent = 1.0):
	add_torque(_rel_vec(Vector3( 1,0,0), safe_stat('turn_rate', percent) * 0.1))

func rotate_down(percent = 1.0):
	add_torque(_rel_vec(Vector3(-1,0,0), safe_stat('turn_rate', percent) * 0.1))

func rotate_left(percent = 1.0):
	add_torque(_rel_vec(Vector3(0, 1,0), safe_stat('turn_rate', percent)*0.25 * 0.1))

func rotate_right(percent = 1.0):
	add_torque(_rel_vec(Vector3(0,-1,0), safe_stat('turn_rate', percent)*0.25 * 0.1))

func roll_left(percent = 1.0):
	add_torque(_rel_vec(Vector3(0,0, 1), safe_stat('turn_rate', percent) * 0.1))

func roll_right(percent = 1.0):
	add_torque(_rel_vec(Vector3(0,0,-1), safe_stat('turn_rate', percent) * 0.1))

func rotation_needs(targetVec):
	var t = get_transform().basis;
	var velo = targetVec.normalized();
	var forward = t.xform(Vector3(0,0,-1));
	var up = t.xform(Vector3(0,1,0))
	return Vector3(up.cross(forward).dot(velo), forward.dot(velo), up.dot(velo));

func align_with(vec, percent_xz = Vector2(1.0,1.0)):
	var euler = rotation_needs(vec);

	var moved = false;
	
	if euler.x >= 0.0:
		rotate_left(max(0.05, abs(euler.x) * 100.0 * percent_xz.x));
		if euler.x >= 0.25:
			roll_left(max(0.05, abs(euler.x) * 10.0 * percent_xz.x));
		moved = true
	elif euler.x < -0.0:
		rotate_right(max(0.05, abs(euler.x) * 100.0 * percent_xz.x));
		if euler.x <= -0.25:
			roll_right(max(0.05, abs(euler.x) * 10.0 * percent_xz.x));	
		moved = true

	if euler.y < 1.0 and euler.z >= 0:
		rotate_up(max(0.05, abs(euler.y - 1) * 10.0 * percent_xz.y));
		moved = true
	elif euler.y < 1 and euler.z < 0:
		rotate_down(max(0.05, abs(euler.y - 1) * 10.0 * percent_xz.y));
		moved = true
	
	## TODO: rotate towards sector-up when idle-ish.

func reverse():
	if driving_mode == DRIVING_MODE.AUTOTHRUST:
		target_speed = max(0, target_speed - 1)
	else:
		align_with(-get_linear_velocity())

func aim_towards_target():
	var target = targetingSystem.get_active_target();
	if target == null:
		target = navSystem.targetNode
	if target == null:
		return

	if target is RigidBody:
		align_with(Intercept.simple_intercept(self, target, 1000)[0])
	else:
		align_with(target.transform.origin - get_transform().origin)

func follow_vector(var world_vector, var percent_xz = Vector2(1.0,1.0)):
	align_with(world_vector, percent_xz)

##############################
##############################
## Weapons system

func start_firing():
	var weapons = get_node('WeaponsSystem').get_children();
	for weapon in weapons:
		weapon.start_firing();
	pass

func stop_firing():
	var weapons = get_node('WeaponsSystem').get_children();
	for weapon in weapons:
		weapon.stop_firing();
	pass

##############################
##############################
## Health

func set_energy(e):
	energy = e;
	if energy < 0:
		energy = 0;

func get_energy(): return energy;

func set_shields(s):
	shields = s;
	if shields < 0:
		shields = 0;

func get_shields(): return shields;

func set_armour(a):
	armour = a;
	if armour < 0:
		armour = 0;
	if armour == 0:
		emit_signal('ship_death', self)
		NodeHelpers.queue_delete(self);

func get_armour(): return armour;

##############################
##############################
## Jumping-related helpers

signal docked(ID, at)
signal undocked(ID, from)
signal jumped(ID, from)
signal unjumped(ID, into)

class HypernavigationData:
	var method = null;
	var to = null;
	var data = null;
	
	func _init(m, t, d = {}):
		to = t
		method = m
		data = d
	
	static func hyperjump(to, from):
		return HypernavigationData.new(
			Enums.HYPERNAVMETHOD.JUMPING,
			to,
			{ 'from': from }
		)
	static func teleport(to, pos):
		return HypernavigationData.new(
			Enums.HYPERNAVMETHOD.TELEPORTING,
			to,
			{ 'position': pos }
		)

class DockingData:
	var status = null;
	var dock = null;
	
	func _init(s, d):
		status = s
		dock = d
	
	static func dock(to):
		return DockingData.new(
			Enums.DOCKSTATUS.DOCKING,
			to
		)
	static func undock(from):
		return DockingData.new(
			Enums.DOCKSTATUS.UNDOCKING,
			from
		)

func _jump_out():
	navSystem.targetNode = null;
	if ID == Core.gameState.playerShipID:
		Core.outsideWorldSim.sector_about_to_unload()
		Core.unload_scene();
	lastSector = currentSector
	currentSector = null
	emit_signal('jumped', ID, lastSector)

func _do_jump(to):
	assert(to != currentSector)
	hyperNavigating = HypernavigationData.hyperjump(to, currentSector)
	_jump_out()

func _teleport(to, pos):
	if to != currentSector:
		hyperNavigating = HypernavigationData.teleport(to, pos)
		_jump_out()
	else:
		translation = pos;

func _do_dock(to):
	dockingProcedure = null;
	if ID == Core.gameState.playerShipID:
		Core.outsideWorldSim.sector_about_to_unload()
		Core.unload_scene();
	docking = null
	dockedAt = to;
	emit_signal('docked', ID, dockedAt)

## These helpers will be called by the outside world or the player
## But they don't handle actual in-scene logic

func _do_undock():
	assert(dockedAt != null)
	if ID == Core.gameState.playerShipID:
		Core.unload_scene();
	docking = DockingData.undock(dockedAt)
	dockedAt = null;
	emit_signal('undocked', ID, docking.dock)
	_undocking_done()

func _do_unjump():
	assert(hyperNavigating != null)
	currentSector = hyperNavigating.to
	emit_signal('unjumped', ID, hyperNavigating.to)
	_unjumping_done()

func _undocking_done():
	docking = null;

func _unjumping_done():
	hyperNavigating = null;

##############################
##############################
## External jumping interface

func jump(to):
	if hyperfuel < 100:
		emit_signal('add_chat_message', 'Not enough fuel for Hyperjump')
		return;
	else:
		hyperfuel -= 100;
	_do_jump(to)

## Teleporting is a bit of a special function anyways
## Player can't trigger it.
func teleport(to, pos):
	_teleport(to, pos)

func dock(to):
	_do_dock(to)

##############################
##############################
## Comms-related

func try_dock():
	if navSystem.targetNode == null:
		return;

	if dockingProcedure != null:
		dockingProcedure.ask_for_docking()
		return

	dockingProcedure = Docking.new(self, navSystem.targetNode)
	dockingProcedure.ask_for_docking()

func on_received_chat(convo, sender, chatData):
	emit_signal('add_chat_message', chatData.message)
	if convo is Docking:
		if chatData.data.type == Docking.DOCKING_NOW:
			dock(sender.ID)
