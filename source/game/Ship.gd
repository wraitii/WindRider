extends RigidBody

const NavSystem = preload('res://source/game/NavSystem.gd')

const Docking = preload('res://source/game/comms/Docking.gd')
const JumpZone = preload('res://source/game/JumpZone.gd')

const Graphics = preload('res://source/graphics/Ship.tscn')

var currentSystem;

export (String) var shipDataName;

var dockingProcedure = null

# subsystems shorthand
var navSystem;
var shipStats;

signal got_chat(convo, sender, chatData)
signal docking(dock)

func _init():
	pass

func init(name):
	navSystem = get_node('NavSystem');
	shipStats = get_node('ShipStats')

	shipDataName = name
	var data = Core.shipsData.get(name)
	shipStats.init(data)
	
	get_node('ShipGraphics').init(data)
	print_tree()
	pass

func _process(delta):
	pass

func _integrate_forces(state):
	var ms = shipStats.get('max_speed')
	
	if state.linear_velocity.length_squared() >= ms*ms*0.8*0.8:
		state.linear_velocity *= 0.99;

	if state.linear_velocity.length_squared() >= ms*ms:
		state.linear_velocity = state.linear_velocity.normalized() * ms;

	set_angular_damp(
		max(
			min(0.7, state.angular_velocity.length_squared()),
			0.4
		)
	)

func thrust(delta):
	var transform = get_transform()
	var pushDir = transform.xform(Vector3(0,0,-1)) - translation

	add_central_force(pushDir * shipStats.get('acceleration'))

func rotate_left(delta):
	add_torque(Vector3(0,shipStats.get('turn_rate'),0)/4.0)

func rotate_right(delta):
	add_torque(Vector3(0,-shipStats.get('turn_rate'),0)/4.0)
	
func dock():
	if navSystem.target == null:
		return;
	
	if navSystem.target is JumpZone:
		if navSystem.target.overlaps_body(self):
			Core.jump(navSystem.target.jumpTo)
		return
	
	if dockingProcedure != null:
		dockingProcedure.try_docking()
		return

	dockingProcedure = Docking.new(self, navSystem.target)
	dockingProcedure.ask_for_docking()

func on_received_chat(convo, sender, chatData):
	emit_signal('got_chat', convo, sender, chatData)
	if convo is Docking:
		if chatData.data.type == Docking.DOCKING_NOW:
			emit_signal('docking', sender)
