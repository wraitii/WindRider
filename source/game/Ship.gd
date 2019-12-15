extends RigidBody

# intended for the human player only
signal add_chat_message(message)

signal ship_death(ship)

const NavSystem = preload('res://source/game/NavSystem.gd')
const Docking = preload('res://source/game/comms/Docking.gd')

var ID;

var dockingProcedure = null

var data;

# subsystems shorthand
var AI;
var navSystem;
var weaponsSystem;
var targetingSystem;
var shipStats;
var hold;

# Navigation
var lastSector = null;
var currentSector = null;
var dockedAt = null;
var hyperNavigating = null;
var docking = null;

var commands = [];
# Temporary global to process commands in integrate_forces
var physState;

## Railroading (aka RR) orients velocity wherever the ship
## is pointing. With 0 RR, the behaviour is Euclidian, with 1 RR, the ship behaves
## a lot more like Star Wars spaceships (and planes on Earth).
## In general, Autothrust and High Railroading are probably the easiest option.
## Autothrust also auto-railroads based on velocity.
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
	pass

func init(shipType):
	Core.outsideWorldSim.assign_id(self);
	navSystem = get_node('NavSystem');
	weaponsSystem = get_node('WeaponsSystem');
	targetingSystem = get_node('TargetingSystem');
	shipStats = get_node('ShipStats');
	AI = get_node('AI');
	hold = get_node('Hold')
	
	data = Core.dataMgr.get('ships/' + shipType)
	shipStats.init(data)
	hold.init(data)
	targetingSystem.init(null, self);
	
	shields = stat('max_shields')
	armour = stat('max_armour')
	energy = stat('max_energy')
	hyperfuel = stat('max_hyperfuel')

	var graph = load('res://data/art/ships/' + data['scene'] + '.tscn')
	var graphics = graph.instance()
	self.add_child(graphics)
	for c in graphics.get_node('Shapes').get_children():
		graphics.get_node('Shapes').remove_child(c)
		add_child(c)

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
	
	ret.hold = hold.serialize()
	
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
	hold = get_node('Hold')
	hold.deserialize(ret.hold)
	
	shipStats.init(data)
	targetingSystem.init(null, self);
	
	var graph = load('res://data/art/ships/' + data['scene'] + '.tscn')
	var graphics = graph.instance()
	self.add_child(graphics)
	for c in graphics.get_node('Shapes').get_children():
		graphics.get_node('Shapes').remove_child(c)
		add_child(c)

	shields = ret.shields
	armour = ret.armour
	energy = ret.energy
	hyperfuel = ret.hyperfuel

func _process(_delta):
	pass

func _physics_process(delta):
	energy += stat('energy_gen') * delta
	if energy > stat('max_energy'):
		energy = stat('max_energy')

##############################
##############################
## Physics

func _integrate_forces(state):
	var speed = state.linear_velocity.length_squared();
	var dir = state.linear_velocity.normalized();

	## M	Ships have a max speed.
	if speed > stat('max_speed') * stat('max_speed'):
		state.linear_velocity = dir * stat('max_speed')

	# Railroading (orient velocity wherever the ship is pointing)
	if not state.linear_velocity.is_equal_approx(Vector3()):
		var up = Vector3(0,1,0)
		if state.linear_velocity.is_equal_approx(up):
			up = Vector3(0,0,1)
		var rot = Quat(Transform().looking_at(state.linear_velocity, up).basis)
		rot = rot.slerp(get_transform().basis, 0.1 * railroading)
		state.linear_velocity = rot.xform(Vector3(0,0,-1)) * state.linear_velocity.length()

	# Commands processing
	# TODO: maybe avoid contradictory or supplementary commands?
	physState = state;
	for command in commands:
		if command is String:
			var fun = command
			call(fun)
		else:
			callv(command[0],command[1])
	commands = []
	physState = null;

func safe_stat(stat, percent):
	return shipStats.get(stat) * max(0, min(1, percent))

# Called before delivering from a landable
func reset_speed_params():
	navSystem.targetSpeed = 0
	railroading = 0

func _phys_vec(vec, stat, power):
	var transform = get_transform()
	var pushDir = transform.xform(vec) - translation
	return pushDir * safe_stat(stat, power) / mass

func thrust(percent = 1.0):
	physState.linear_velocity += _phys_vec(Vector3(0,0,-1), 'acceleration', percent) / 200.0

func reverse_thrust(percent = 1.0):
	physState.linear_velocity -= _phys_vec(Vector3(0,0,-1), 'acceleration', percent) / 200.0

func rotate_up(percent = 1.0):
	physState.angular_velocity += _phys_vec(Vector3(1,0,0), 'turn_rate', percent) / 100.0

func rotate_down(percent = 1.0):
	physState.angular_velocity -= _phys_vec(Vector3(1,0,0), 'turn_rate', percent) / 100.0

func rotate_left(percent = 1.0):
	physState.angular_velocity += _phys_vec(Vector3(0,1,0), 'turn_rate', percent) / 500.0

func rotate_right(percent = 1.0):
	physState.angular_velocity -= _phys_vec(Vector3(0,1,0), 'turn_rate', percent) / 500.0

func roll_left(percent = 1.0):
	physState.angular_velocity += _phys_vec(Vector3(0,0,1), 'turn_rate', percent) / 100.0

func roll_right(percent = 1.0):
	physState.angular_velocity -= _phys_vec(Vector3(0,0,1), 'turn_rate', percent) / 100.0

func rotation_needs(targetVec):
	var t = get_transform().basis;
	var velo = targetVec.normalized();
	var forward = t.xform(Vector3(0,0,-1));
	var up = t.xform(Vector3(0,1,0))
	return Vector3(up.cross(forward).dot(velo), forward.dot(velo), up.dot(velo));

func align_with(vec, percent_xz = Vector2(1.0,1.0)):
	var euler = rotation_needs(vec);
	
	if euler.x >= 0.0:
		rotate_left(max(0.05, abs(euler.x) * 10.0) * percent_xz.x);
		if euler.x >= 0.25:
			roll_left(max(0.05, abs(euler.x) * 10.0) * percent_xz.x);
	elif euler.x < -0.0:
		rotate_right(max(0.05, abs(euler.x) * 10.0) * percent_xz.x);
		if euler.x <= -0.25:
			roll_right(max(0.05, abs(euler.x) * 10.0) * percent_xz.x);	

	if euler.y < 1.0 and euler.z >= 0:
		rotate_up(max(0.05, abs(euler.y - 1) * 10.0) * percent_xz.y);
	elif euler.y < 1 and euler.z < 0:
		rotate_down(max(0.05, abs(euler.y - 1) * 10.0) * percent_xz.y);
	
	## TODO: rotate towards sector-up when idle-ish.

func reverse():
	align_with(-get_linear_velocity())

func aim_towards_target():
	var target = targetingSystem.get_active_target();
	if target == null:
		target = navSystem.get_next_waypoint_position()

	if target == null:
		return

	if target is RigidBody:
		align_with(Intercept.simple_intercept(self, target, 1000)[0])
	else:
		align_with(target - get_transform().origin)

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
	navSystem.reset()
	if ID == Core.gameState.playerShipID:
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
	if !navSystem.has_target():
		return;

	var target = navSystem.get_target()
	if target.type != target.TARGET_TYPE.LANDABLE:
		return;

	if dockingProcedure != null:
		dockingProcedure.ask_for_docking()
		return

	dockingProcedure = Docking.new(self, Core.landablesMgr.get(target.ID))
	dockingProcedure.ask_for_docking()

func on_received_chat(convo, sender, chatData):
	emit_signal('add_chat_message', chatData.message)
	if convo is Docking:
		if chatData.data.type == Docking.DOCKING_NOW:
			dock(sender.ID)
