extends Camera

enum CAMERA_STATES { FOLLOW, FOLLOW_FROM_ABOVE, FOLLOW_FROM_SHIP }
export (CAMERA_STATES) var mode = CAMERA_STATES.FOLLOW;

var followedShip = null;
var followerShip = null;

func _ready():
	if !Core.gameState.cameraMode:
		Core.gameState.cameraMode = CAMERA_STATES.FOLLOW
	mode = Core.gameState.cameraMode;
	_init_mode()
	pass

func _physics_process(delta):
	if !followedShip:
		return
	
	var trans = followedShip.get_global_transform()

	match mode:
		CAMERA_STATES.FOLLOW:
			var pos = Vector3(0,1.5,5.0) * 9;
			var vec = trans.xform(pos)
			var lookat = trans.xform(pos + Vector3(0,0,-1)*1000)
			var up = trans.xform(Vector3(0,1,0)) - trans.origin
			var target = Transform(Basis(), vec).looking_at(lookat, up)
			transform = transform.interpolate_with(target, 0.2)
			#transform.origin = transform.origin.linear_interpolate(vec, 0.2)
			#transform.basis = transform.basis.slerp(trans.basis, 1)
			#rotate_object_local(Vector3(0,1,0),-PI/2.0)
		CAMERA_STATES.FOLLOW_FROM_ABOVE:
			var pos = trans.origin
			pos.y += 200.0
			transform.origin = pos
			transform.basis = Basis()
			#rotate_object_local(Vector3(0,1,0),-PI/2.0)
			rotate_object_local(Vector3(1,0,0),-PI/2.0)
		CAMERA_STATES.FOLLOW_FROM_SHIP:
			if followerShip == null:
				switch_mode();
			var pos = trans.origin
			var dir = trans.origin - followerShip.transform.origin
			pos = pos - dir.normalized() * 10
			look_at_from_position(pos, trans.origin, followerShip.transform.basis.xform(Vector3(0,1,0)))
	return

func switch_mode():
	mode = mode + 1;
	if mode == CAMERA_STATES.FOLLOW_FROM_SHIP and followerShip == null:
		mode = mode + 1
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
