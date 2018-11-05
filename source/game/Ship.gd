extends RigidBody

const default_orientation = Vector3(1,0,0)

export (float) var max_speed = 10.0
export (float) var acceleration = 10.0
export (float) var speed_friction

const Docking = preload('res://source/game/comms/docking.gd')

var dockingProcedure = null

signal got_chat(convo, sender, chatData)

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

# input
func thrust(delta):
	var transform = get_transform()
	var pushDir = transform.xform(default_orientation) - translation

	add_central_force(pushDir * acceleration)

func rotate_left(delta):
	add_torque(Vector3(0,1,0))

func rotate_right(delta):
	add_torque(Vector3(0,-1,0))

func dock(delta):
	if dockingProcedure != null:
		dockingProcedure.try_docking()
		return

	var coll = get_node('/root/InGameRoot/SystemGraph/Landable')

	dockingProcedure = Docking.new()
	dockingProcedure.set_sender(self)
	dockingProcedure.set_receiver(coll)
	dockingProcedure.ask_for_docking()

func on_received_chat(convo, sender, chatData):
	emit_signal('got_chat', convo, sender, chatData)
	if convo is Docking:
		if chatData.data.type == Docking.DOCKING_NOW:
			get_tree().change_scene('res://source/game/test.tscn')