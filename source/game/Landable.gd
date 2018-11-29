extends Area

const Graphics = preload('res://data/art/landables/Landable.tscn')

var graphics;

var area;
var ID;
var position;

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
	
	var collShape = CollisionShape.new()
	var shape = CylinderShape.new()
	shape.height= 10.0;
	shape.radius = 1.0;
	collShape.shape = shape
	add_child(collShape)

	for c in data['society_presence']:
		assert(Core.societyMgr.get(c['ID']) != null)
		societyPresence[c['ID']] = c['presence']

################
################
### Docking

func deliver(obj):
	obj.translation = translation
	obj.translation.y = 0;
	obj.linear_velocity = Vector3(0,0,0)
	obj.angular_velocity = Vector3(0,0,0)
	get_parent().get_parent().add_child(obj)

const Docking = preload('res://source/game/comms/Docking.gd')

func on_received_chat(convo, sender, chatData):
	if convo is Docking:
		if chatData.data.type == Docking.ASK_DOCKING:
			ack_docking_request(convo, sender, chatData)
		elif chatData.data.type == Docking.DOCKING_TRY:
			dock(convo, sender, chatData)

func ack_docking_request(convo, requester, data):
	convo.allow_docking()

func dock(convo, requester, data):
	if convo.docking_status != Docking.DOCKING_OK:
		convo.refuse_docking()
		return;
	
	if !(requester is PhysicsBody):
		convo.refuse_docking()
		return;

	if !self.overlaps_body(requester):
		convo.too_far_away()
		return;

	if requester.get_linear_velocity().length_squared() > 5*5:
		convo.send_to_sender("You are moving too fast to dock",Docking.DOCKING_TOO_FAST)
		return;
	
	convo.dock()