extends Camera

const MyClass = preload("Player.gd")

enum CAMERA_STATES { FOLLOW, FOLLOW_FROM_ABOVE }
export (CAMERA_STATES) var mode = FOLLOW;

var followedShip = null;

func _ready():
	pass

func _process(delta):
	if !followedShip:
		return
	
	var trans = followedShip.get_global_transform()

	match mode:
		FOLLOW:
			var pos = Vector3(0,1.5,3.0);
			var vec = trans.xform(pos)
			transform.origin = vec
			transform.basis = trans.basis
			#rotate_object_local(Vector3(0,1,0),-PI/2.0)
		FOLLOW_FROM_ABOVE:
			var pos = Vector3(0.0,40.0,0);
			var vec = trans.xform(pos)
			transform.origin = vec
			transform.basis = trans.basis
			#rotate_object_local(Vector3(0,1,0),-PI/2.0)
			rotate_object_local(Vector3(1,0,0),-PI/2.0)

	return

func switch_mode():
	mode = mode + 1;
	if mode >= len(CAMERA_STATES):
		mode = FOLLOW;