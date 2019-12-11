extends Node

const Ship = preload('Ship.gd')
const Society = preload('Society.gd')

var graphics;

var ID;
var _raw;
var position;
var sectorID;

var administrator;

### 0-100
var societyPresence = {};

func _enter_tree():
	add_to_group('Landables', true)

	var LandableGraphics = load('res://data/art/landables/' + _raw['graphics'] + '/' + _raw['graphics'] + '.tscn')
	graphics = LandableGraphics.instance()
	graphics.translate(position)
	graphics.scale_object_local(Vector3(10,10,10))
	add_child(graphics)
	if graphics.has_node("AutoDockArea"):
		graphics.get_node("AutoDockArea").connect("body_entered", self, 'on_autodock_entered')

func _exit_tree():
	remove_from_group('Landables')
	remove_child(graphics)
	graphics = null;
	
func init(data):
	_raw = data
	ID = data.ID
	position = Vector3(data['position'][0],data['position'][1],data['position'][2])
	
	for c in data['society_presence']:
		assert(Core.societyMgr.get(c['ID']) != null)
		societyPresence[c['ID']] = c['presence']
	
	administrator = Society.new()
	
################
################
### Docking

func deliver(obj):
	assert(graphics.has_node('Exit'))
	obj.global_transform.origin = graphics.get_node('Exit').global_transform.origin
	obj.global_transform.basis = Basis(graphics.get_node('Exit').global_transform.basis.get_rotation_quat())
	obj.reset_speed_params()
	obj.linear_velocity = Vector3(0,0,0)
	obj.angular_velocity = Vector3(0,0,0)
	get_parent().get_parent().add_child(obj)

signal trigger_dock

func on_autodock_entered(body):
	if body is Ship:
		emit_signal('trigger_dock', body)

const Docking = preload('res://source/game/comms/Docking.gd')

func on_received_chat(convo, sender, chatData):
	if convo is Docking:
		dock(convo, sender, chatData)

func dock(convo, requester, data):
	if convo.docking_status == Docking.DOCKING_OK:
		convo.still_ok()
		return
	
	if data.data.type == Docking.ASK_DOCKING:
		convo.allow_docking()
		return;

	# placeholder
	if convo.docking_status != Docking.DOCKING_OK:
		convo.refuse_docking()
		return;
	
	if !(requester is PhysicsBody):
		convo.refuse_docking()
		return;
