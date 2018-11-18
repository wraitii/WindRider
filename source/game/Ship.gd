extends RigidBody

const NavSystem = preload('res://source/game/NavSystem.gd')

const Docking = preload('res://source/game/comms/Docking.gd')
const JumpZone = preload('res://source/game/JumpZone.gd')

const Graphics = preload('res://source/graphics/Ship.tscn')

var ID;
var dockedAt = null;

export (String) var shipDataName;

var dockingProcedure = null

# subsystems shorthand
var navSystem;
var shipStats;

signal got_chat(convo, sender, chatData)
signal docking(ship, dock)
signal undocking(ship)
signal jumping(ship, to)
signal teleporting(ship, to, pos)

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

func teleport(to, pos):
	navSystem.targetNode = null;
	if self.is_inside_tree():
		get_parent().remove_child(self)
	emit_signal('teleporting', self, to, pos)
	
func do_jump(to):
	navSystem.targetNode = null;
	if self.is_inside_tree():
		get_parent().remove_child(self)
	emit_signal('jumping', self, to)

func try_dock():
	if navSystem.targetNode == null:
		return;
	
	if navSystem.targetNode is JumpZone:
		if navSystem.targetNode.overlaps_body(self):
			do_jump(navSystem.targetNode.jumpTo)
		return

	if dockingProcedure != null:
		dockingProcedure.try_docking()
		return

	dockingProcedure = Docking.new(self, navSystem.targetNode)
	dockingProcedure.ask_for_docking()

func do_dock(to):
	dockingProcedure = null;
	if self.is_inside_tree():
		get_parent().remove_child(self)
	emit_signal('docking', self, to.data.name)

func do_undock():
	if self.is_inside_tree():
		get_parent().remove_child(self)
	emit_signal('undocking', self)

func on_received_chat(convo, sender, chatData):
	emit_signal('got_chat', convo, sender, chatData)
	if convo is Docking:
		if chatData.data.type == Docking.DOCKING_NOW:
			do_dock(sender)
