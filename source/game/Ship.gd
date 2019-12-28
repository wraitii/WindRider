extends RigidBody

# intended for the human player only
signal add_chat_message(message)


signal ship_death(ship)

signal will_dock(ship)
signal docked(ship)
signal will_undock(ship)
signal undocked(ship)
signal jump_out(ship)
signal will_jump_in(ship)
signal jumped_in(ship)

const NavSystem = preload('res://source/game/NavSystem.gd')
const Docking = preload('res://source/game/comms/Docking.gd')

var ID;
var data;

# Link to Character owning the ship
var ownerChar = null;

# subsystems shorthand
var AI;
var navSystem;
var targetingSystem;
var autopilot;
var weaponsSystem;
var shipStats;
var hold;

var graphics;

# Navigation
var lastSector = null;
var currentSector = null;
var dockedAt = null;
var hyperNavigating = null;
var dockingProcess = null;
var dockingConvo = null

# Holds command until _integrate_forces is called
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

func init(shipData):
	ID = shipData.ID
	data = Core.dataMgr.get('ships/' + shipData['model'])

	navSystem = get_node('NavSystem');
	targetingSystem = get_node('TargetingSystem');
	autopilot = get_node('Autopilot')
	weaponsSystem = get_node('WeaponsSystem');
	shipStats = get_node('ShipStats');
	AI = get_node('AI');
	hold = get_node('Hold')
	
	hold.init(data)
	weaponsSystem.init()
	targetingSystem.init(null, self);
	
	if 'components' in data:
		for comp in data['components']:
			install_component(comp, false)

	shipStats._compute_stats()

	shields = stat('max_shields')
	armour = stat('max_armour')
	energy = stat('max_energy')
	hyperfuel = stat('max_hyperfuel')

	var graph = load('res://data/art/ships/' + data['scene'] + '.tscn')
	graphics = graph.instance()
	add_child(graphics)
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
	ret.dockingProcess = dockingProcess
	
	ret.hold = hold.serialize()
	ret.shipStats = shipStats.serialize()

	return ret;

func deserialize(ret):
	for prop in ret:
		if prop in self:
			set(prop, ret[prop])
	
	navSystem = get_node('NavSystem');
	targetingSystem = get_node('TargetingSystem');
	autopilot = get_node('Autopilot')
	weaponsSystem = get_node('WeaponsSystem');
	shipStats = get_node('ShipStats')
	AI = get_node('AI');
	hold = get_node('Hold')
	
	hold.deserialize(ret.hold)

	weaponsSystem.init()
	shipStats.deserialize(ret.shipStats)

	targetingSystem.init(null, self);

	var graph = load('res://data/art/ships/' + data['scene'] + '.tscn')
	graphics = graph.instance()
	add_child(graphics)
	for c in graphics.get_node('Shapes').get_children():
		graphics.get_node('Shapes').remove_child(c)
		add_child(c)

func _process(_delta):
	pass

func _physics_process(delta):
	if !is_inside_tree():
		return
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

func reverse(percent):
	align_with(-get_linear_velocity(), Vector2(1,1) * percent)

func follow_vector(var world_vector, var percent_xz = Vector2(1.0,1.0)):
	align_with(world_vector, percent_xz)

##############################
##############################
## General Components

const Component = preload('Component.gd')


func can_install(componentID):
	var data = Core.dataMgr.get('ship_components/' + componentID)
	var ress = Component.ress(data)
	if !('max_per_hold' in data):
		return true

	var cs;
	if ('hold_type' in data):
		cs = hold.can_store(ress, null, hold.HOLD_TYPE[data['hold_type']])
	else:
		cs = hold.can_store(ress)
	return cs[0]

func install_component(componentID, flush_stats = true):
	var comp = Component.new()
	comp.init(Core.dataMgr.get('ship_components/' + componentID))
	
	if 'max_per_hold' in comp:
		var ress = Component.ress(comp)
		var cs;
		if ('hold_type' in comp):
			cs = hold.can_store(ress, null, hold.HOLD_TYPE[comp['hold_type']])
		else:
			cs = hold.can_store(ress)
		assert(cs[0])
		ress.components = [comp]
		hold.store(ress, cs[1])

	# Component has safely been stored. We install it.
	shipStats.install(comp)

	if flush_stats:
		shipStats._compute_stats()

func uninstall_component(ID, flush_stats = true):
	if !(ID in shipStats.installedComps):
		return
	var comp = shipStats.installedComps[ID].pop_back()

	for idx in comp.holdIndices:
		hold.holdContent[idx].components.erase(comp)

	shipStats.uninstall(comp)

	if flush_stats:
		shipStats._compute_stats()

func get_installed(ID):
	if ID in shipStats.installedComps:
		return shipStats.installedComps[ID]
	return []

func get_all_installed():
	return shipStats.installedComps

##############################
##############################
## Weapons system

func start_firing():
	get_node('WeaponsSystem').start_firing()

func stop_firing():
	get_node('WeaponsSystem').stop_firing()

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

func get_armour(): return armour;

##############################
##############################
## Jump/Dock-ing 
## The jumping and docking are jointly handled by the ship and the outsideWorldSim
## functions starting with '_on' are to be solely called by the outsideWorldSim.

#### Jumping

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

func jump(to):
	if hyperfuel < 100:
		emit_signal('add_chat_message', 'Not enough fuel for Hyperjump')
		return;
	else:
		hyperfuel -= 100;
	hyperNavigating = HypernavigationData.hyperjump(to, currentSector)
	_jump_out()

func teleport(to, pos):
	if to != currentSector:
		hyperNavigating = HypernavigationData.teleport(to, pos)
		if currentSector:
			_jump_out()
		else:
			# This is the exceptional bit in teleport
			_on_jump_in()
	else:
		translation = pos;

func _jump_out():
	assert(currentSector)
	emit_signal('jump_out', self)
	lastSector = currentSector
	currentSector = null
	targetingSystem.reset()

func _on_jump_in():
	assert(hyperNavigating.to)
	currentSector = hyperNavigating.to
	emit_signal('will_jump_in', self)
	hyperNavigating = null;
	emit_signal('jumped_in', self)

#### Docking

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

func undock():
	assert(dockedAt != null)
	dockingProcess = DockingData.undock(dockedAt)
	emit_signal('will_undock', self)

func dock(to):
	dockingProcess = DockingData.dock(to)
	targetingSystem.reset()
	emit_signal("will_dock", self)

func _on_dock():
	dockedAt = dockingProcess.dock;
	dockingConvo = null;
	dockingProcess = null
	emit_signal('docked', self)

func _on_undock():
	dockedAt = null;
	dockingProcess = null;
	emit_signal('undocked', self)

##############################
##############################
## Comms-related

func try_dock():
	if !navSystem.has_target():
		return;

	var target = navSystem.get_active_target()
	if target.type != target.TARGET_TYPE.LANDABLE:
		return;

	if dockingConvo != null:
		dockingConvo.ask_for_docking()
		return

	dockingConvo = Docking.new(self, Core.landablesMgr.get(target.ID))
	dockingConvo.ask_for_docking()

func on_received_chat(convo, sender, chatData):
	emit_signal('add_chat_message', chatData.message)
	if convo is Docking:
		if chatData.data.type == Docking.DOCKING_NOW:
			dock(sender.ID)
