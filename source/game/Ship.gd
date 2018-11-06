extends RigidBody

const Docking = preload('res://source/game/comms/Docking.gd')

const default_orientation = Vector3(1,0,0)

export (float) var max_speed = 10.0
export (float) var acceleration = 10.0
export (float) var speed_friction

var target = null;

var dockingProcedure = null

signal got_chat(convo, sender, chatData)
signal docking(dock)

func _init():
	pass

func _ready():
	speed_friction = max_speed * 0.8
	pass

func _process(delta):
	pass

func _integrate_forces(state):
	if state.linear_velocity.length_squared() >= speed_friction*speed_friction:
		state.linear_velocity *= 0.99;

	if state.linear_velocity.length_squared() >= max_speed*max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed;

	set_angular_damp(min(0.7, state.angular_velocity.length_squared()))

func thrust(delta):
	var transform = get_transform()
	var pushDir = transform.xform(default_orientation) - translation

	add_central_force(pushDir * acceleration)

func rotate_left(delta):
	add_torque(Vector3(0,4,0))

func rotate_right(delta):
	add_torque(Vector3(0,-4,0))

func target_best_landable():
	var landables = get_tree().get_nodes_in_group('Landable')
	var bestLandable = [null,null]
	for landable in landables:
		var dist = landable.translation.distance_squared_to(self.translation)
		if bestLandable[1] == null || dist <= bestLandable[1]:
			bestLandable[0] = landable;
			bestLandable[1] = dist;
	target = bestLandable[0]
	
func dock():
	if target == null:
		return;
		
	if dockingProcedure != null:
		dockingProcedure.try_docking()
		return

	dockingProcedure = Docking.new(self, target)
	dockingProcedure.ask_for_docking()

func on_received_chat(convo, sender, chatData):
	emit_signal('got_chat', convo, sender, chatData)
	if convo is Docking:
		if chatData.data.type == Docking.DOCKING_NOW:
			emit_signal('docking', sender)
