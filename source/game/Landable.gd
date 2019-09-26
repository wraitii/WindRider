extends Area

const Ship = preload('Ship.gd')
const Graphics = preload('res://data/art/landables/Landable.tscn')

var graphics;

var area;
var ID;
var position;
var sector;

### 0-100
var societyPresence = {};

func _enter_tree():
	add_to_group('Landables', true)
	graphics = Graphics.instance()
	add_child(graphics)
	
func _exit_tree():
	remove_from_group('Landables')
	remove_child(graphics)
	graphics = null;
	
func init(data):
	ID = data.ID
	position = Vector3(data['position'][0],data['position'][1],data['position'][2])
	translate(position)
	scale_object_local(Vector3(10,10,10))
	
	for c in data['society_presence']:
		assert(Core.societyMgr.get(c['ID']) != null)
		societyPresence[c['ID']] = c['presence']

################
################
### Docking

func deliver(obj):
	obj.translation = translation + Vector3(20,0,0)
	obj.translation.y = 0;
	obj.linear_velocity = Vector3(0,0,0)
	obj.angular_velocity = Vector3(0,0,0)
	get_parent().get_parent().add_child(obj)

signal trigger_dock

func on_body_entered(body):
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
	

