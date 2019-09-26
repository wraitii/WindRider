extends Spatial

var ownerSector;
var jumpTo : String;
var position : Vector3;
var direction : Vector3;

func init(o, d):
	ownerSector = o
	jumpTo = d['jump_to'];
	position = Vector3(d['position'][0], 0.0, d['position'][1]);
	# defer direction to graphics to avoid a data race

func _enter_tree():
	add_to_group('JumpZones', true)
	init_graphics();
	self.connect('body_entered', self, 'on_body_entered')

func _exit_tree():
	remove_from_group('JumpZones')

func init_graphics():
	var jumpSys = Core.sectorsMgr.get(jumpTo)

	direction = (jumpSys.position - position).normalized()
	
	var up_dir = Vector3(0, 1, 0)
	if direction == up_dir:
		up_dir = Vector3(-1,0,0)
	
	look_at_from_position(position, direction, up_dir)
	# pretend sectors are XY, not XZ aligned
	# so that in general jump zones point UP
	rotate_object_local(Vector3(1,0,0),PI/2.0)
	get_node('Viewport/Jump Name').set_text(jumpTo);

func deliver(obj):
	var target = -direction
	var up = Vector3(0,1,0)
	if target == up:
		up = Vector3(1,0,0)
	obj.look_at_from_position(translation + target * 50, target, up)
	obj.linear_velocity = Vector3()
	get_parent().get_parent().add_child(obj)

const Ship = preload('res://source/game/Ship.gd')

func on_body_entered(body):
	if body is Ship:
		body.call_deferred('jump', jumpTo)

const Docking = preload('res://source/game/comms/Docking.gd')
	
func on_received_chat(convo, sender, chatData):
	if convo is Docking:
		convo.allow_docking()
		return
