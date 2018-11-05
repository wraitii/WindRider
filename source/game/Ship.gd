extends RigidBody

const default_orientation = Vector3(1,0,0)

func _ready():
	pass

func _process(delta):
	pass

func _integrate_forces(state):
	if state.linear_velocity.length_squared() >= 8*8:
		state.linear_velocity *= 0.99;

# input
func thrust(delta):
	var transform = get_transform()
	var pushDir = transform.xform(default_orientation) - translation

	add_central_force(pushDir * 10.0)

func rotate_left(delta):
	add_torque(Vector3(0,1,0))

func rotate_right(delta):
	add_torque(Vector3(0,-1,0))

func dock(delta):
	var coll = get_node('/root/InGameRoot/SystemGraph/Landable')
	if !coll.overlaps_body(self):
		return
	
	get_tree().change_scene('res://source/game/test.tscn')
