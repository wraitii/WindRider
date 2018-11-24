extends RigidBody

const NavSystem = preload('res://source/game/NavSystem.gd')

const Docking = preload('res://source/game/comms/Docking.gd')
const JumpZone = preload('res://source/game/JumpZone.gd')

const Graphics = preload('res://source/graphics/Ship.tscn')

var ID;
export (String) var shipDataName;


var dockingProcedure = null

var lastSystem = null;
var currentSystem = null;
var dockedAt = null;

var hyperNavigating = null;
var docking = null;

# subsystems shorthand
var navSystem;
var shipStats;

signal got_chat(convo, sender, chatData)

signal docked(ID, at)
signal undocked(ID, from)
signal jumped(ID, from)
signal unjumped(ID, into)

func _init():
	set_angular_damp(1.0);
	add_to_group('Ships', true)
	pass

func init(name):
	Core.outsideWorldSim.assign_id(self);
	navSystem = get_node('NavSystem');
	shipStats = get_node('ShipStats')

	shipDataName = name
	var data = Core.shipsData.get(name)
	shipStats.init(data)
	
	get_node('ShipGraphics').init(data)
	pass

func _process(delta):
	pass

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

func thrust(delta):
	var transform = get_transform()
	var pushDir = transform.xform(Vector3(0,0,-1)) - translation

	add_central_force(pushDir * shipStats.get('acceleration'))

func rotate_left(delta):
	add_torque(Vector3(0,shipStats.get('turn_rate')*25,0))

func rotate_right(delta):
	add_torque(Vector3(0,-shipStats.get('turn_rate')*25,0))

func reverse(delta):
	var reva = get_transform().basis.xform(Vector3(0,0,-1))
	var cross = reva.cross(get_linear_velocity().normalized())
	if cross.y > 0:
		rotate_right(0);
	elif cross.y < 0:
		rotate_left(0);

##############################
##############################
## Jumping-related helpers

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
	Core.unload_scene()
	docking = null
	dockedAt = to;
	emit_signal('docked', ID, dockedAt)

## These helpers will be called by the outside world or the player
## But they don't handle actual in-scene logic

func _do_undock():
	assert(dockedAt != null)
	Core.unload_scene()
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
	_do_jump(to)

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
	emit_signal('got_chat', convo, sender, chatData)
	if convo is Docking:
		if chatData.data.type == Docking.DOCKING_NOW:
			dock(sender.data.name)
