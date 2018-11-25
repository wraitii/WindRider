extends Camera

enum CAMERA_STATES { FOLLOW, FOLLOW_FROM_ABOVE }
export (CAMERA_STATES) var mode = CAMERA_STATES.FOLLOW_FROM_ABOVE;

var followedShip = null;

func _ready():
	if !Core.gameState.cameraMode:
		Core.gameState.cameraMode = CAMERA_STATES.FOLLOW_FROM_ABOVE
	mode = Core.gameState.cameraMode;
	_init_mode()
	pass

func _process(delta):
	if !followedShip:
		return
	
	var trans = followedShip.get_global_transform()

	match mode:
		CAMERA_STATES.FOLLOW:
			var pos = Vector3(0,1.5,3.0);
			var vec = trans.xform(pos)
			transform.origin = vec
			transform.basis = trans.basis
			#rotate_object_local(Vector3(0,1,0),-PI/2.0)
		CAMERA_STATES.FOLLOW_FROM_ABOVE:
			var pos = trans.origin
			pos.y += 200.0
			transform.origin = pos
			transform.basis = Basis()
			#rotate_object_local(Vector3(0,1,0),-PI/2.0)
			rotate_object_local(Vector3(1,0,0),-PI/2.0)
	return

func switch_mode():
	mode = mode + 1;
	if mode >= len(CAMERA_STATES):
		mode = CAMERA_STATES.FOLLOW;
	_init_mode()

func _init_mode():
	Core.gameState.cameraMode = mode
	match mode:
		CAMERA_STATES.FOLLOW:
			fov = 60
		CAMERA_STATES.FOLLOW_FROM_ABOVE:
			fov = 15