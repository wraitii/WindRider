extends RigidBody

# intended for the human player only
signal add_chat_message(message)

const NavSystem = preload('res://source/game/NavSystem.gd')
const Docking = preload('res://source/game/comms/Docking.gd')
const JumpZone = preload('res://source/game/JumpZone.gd')
const Graphics = preload('res://source/graphics/Ship.tscn')

var ID;

var dockingProcedure = null

var data;

# subsystems shorthand
var navSystem;
var weaponsSystem;
var targetingSystem;
var shipStats;

# Navigation
var lastSystem = null;
var currentSystem = null;
var dockedAt = null;
var hyperNavigating = null;
var docking = null;

## Ship caracteristics
var hyperfuel = null
var energy = null setget set_energy, get_energy;
var shields = null setget set_shields, get_shields;
var armour = null setget set_armour, get_armour;

func stat(stat):
	return shipStats.get(stat)

func _init():
	set_angular_damp(1.0);
	add_to_group('Ships', true)
	pass

func init(shipType):
	Core.outsideWorldSim.assign_id(self);
	navSystem = get_node('NavSystem');
	weaponsSystem = get_node('WeaponsSystem');
	targetingSystem = get_node('TargetingSystem');
	shipStats = get_node('ShipStats')
	
	data = Core.shipsData.get(shipType)
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
	ret.lastSystem = lastSystem
	ret.currentSystem = currentSystem
	ret.dockedAt = dockedAt
	ret.hyperNavigating = hyperNavigating
	ret.docking = docking
	
	return ret;

func deserialize(ret):
	ID = ret.ID
	data = ret.data
	
	lastSystem = ret.lastSystem
	currentSystem = ret.currentSystem
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

##############################
##############################
## Physics

func _integrate_forces(state):
	var ms = shipStats.get('max_speed')
	
	if state.linear_velocity.length_squared() >= ms*ms*0.8*0.8:
		var dec = state.linear_velocity.length_squared() - ms*ms*0.8*0.8;
		dec /= ms*ms*0.2*0.2
		dec *= 0.0005;
		state.linear_velocity *= (1.0 - dec);

	if state.linear_velocity.length_squared() >= ms*ms:
		state.linear_velocity = state.linear_velocity.normalized() * ms;
	
	## Kestrel regulator AKA 'keeping you at y=0'
	
	if abs(translation.y) >= 0.1:
		#var framesToZero = translation.y / (state.linear_velocity.y / state.get_step())
		var kestrelVel = state.linear_velocity
		kestrelVel.y = -translation.y / state.get_step() / 5.0;
		state.linear_velocity = kestrelVel
	
	var up_dir = Vector3(0, 1, 0)
	var cur_dir = state.transform.basis.xform(Vector3(0, 0, -1))
	var target_dir = state.transform.origin + -up_dir * cur_dir.dot(up_dir) + cur_dir;
	var rotation_angle = acos(cur_dir.y) - acos(target_dir.y)
	var right_dir = cur_dir.cross(up_dir);
	if abs(cur_dir.y) >= 0.001:
		state.add_torque(rotation_angle*100.0*right_dir*mass);
	#state.set_angular_velocity(up_dir * (rotation_angle / state.get_step()))

func thrust(delta):
	var transform = get_transform()
	var pushDir = transform.xform(Vector3(0,0,-1)) - translation

	add_central_force(pushDir * shipStats.get('acceleration'))

func rotate_left(delta):
	add_torque(Vector3(0,shipStats.get('turn_rate')*10,0))

func rotate_right(delta):
	add_torque(Vector3(0,-shipStats.get('turn_rate')*10,0))

func rotate_left_small(delta):
	add_torque(Vector3(0,shipStats.get('turn_rate')*2,0))

func rotate_right_small(delta):
	add_torque(Vector3(0,-shipStats.get('turn_rate')*2,0))

func aim_towards_target(delta):
	var target = targetingSystem.get_active_target();
	if target == null:
		target = navSystem.targetNode
	if target == null:
		return;

	var cross = (target.transform.origin - transform.origin).normalized().cross(transform.basis.xform(Vector3(0,0,-1)))
	if cross.y > 0.1:
		rotate_right(0);
	elif cross.y > 0:
		rotate_right_small(0);
	elif cross.y < -0.1:
		rotate_left(0);
	elif cross.y < 0:
		rotate_left_small(0);

func reverse(delta):
	var reva = get_transform().basis.xform(Vector3(0,0,-1))
	var cross = reva.cross(get_linear_velocity().normalized())
	if cross.y > 0.1:
		rotate_right(0);
	elif cross.y > 0:
		rotate_right_small(0);
	elif cross.y < -0.1:
		rotate_left(0);
	elif cross.y < 0:
		rotate_left_small(0);

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
		Core.unload_scene();
	lastSystem = currentSystem
	currentSystem = null
	emit_signal('jumped', ID, lastSystem)

func _do_jump(to):
	assert(to != currentSystem)
	hyperNavigating = HypernavigationData.hyperjump(to, currentSystem)
	_jump_out()

func _teleport(to, pos):
	if to != currentSystem:
		hyperNavigating = HypernavigationData.teleport(to, pos)
		_jump_out()
	else:
		translation = pos;

func _do_dock(to):
	dockingProcedure = null;
	if ID == Core.gameState.playerShipID:
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
	currentSystem = hyperNavigating.to
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
	
	if navSystem.targetNode is JumpZone:
		if navSystem.targetNode.overlaps_body(self):
			jump(navSystem.targetNode.jumpTo)
		return

	if dockingProcedure != null:
		dockingProcedure.try_docking()
		return

	dockingProcedure = Docking.new(self, navSystem.targetNode)
	dockingProcedure.ask_for_docking()

func on_received_chat(convo, sender, chatData):
	emit_signal('add_chat_message', chatData.message)
	if convo is Docking:
		if chatData.data.type == Docking.DOCKING_NOW:
			dock(sender.data.name)
