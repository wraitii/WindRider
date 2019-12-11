extends Spatial

var ownerSector;
var jumpTo : String;
var position : Vector3;
var direction : Vector3;

func init(ownerSectorID, d):
	ownerSector = ownerSectorID
	jumpTo = d['jump_to'];
	position = Vector3(d['position'][0], 0.0, d['position'][1]);
	var jumpSys = Core.systemsMgr.get(Core.sectorsMgr.get(jumpTo).system)
	var currSys = Core.systemsMgr.get(Core.sectorsMgr.get(ownerSector).system)
	direction = (A2V._3(currSys.position) - A2V._3(jumpSys.position)).normalized()

	var up_dir = Vector3(0, 1, 0)
	if direction.is_equal_approx(up_dir):
		up_dir = Vector3(-1,0,0)
	
	look_at_from_position(position, direction*10000, up_dir)
	get_node("JumpTo Tag/Tag Viewport/Label").set_text(jumpTo);

func _ready():
	add_to_group('JumpZones', true)
	
	# TODO: get a whole convo going and gorce going through all 3 jump zones.
	$WarpFinal.connect('body_entered', self, 'on_body_entered')

func _exit_tree():
	remove_from_group('JumpZones')

func deliver(obj):
	var target = direction
	var up = Vector3(0,1,0)
	if target == up:
		up = Vector3(1,0,0)
	obj.look_at_from_position(translation + target * 50, translation + target * 100, up)
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
