extends Area

var data;

func _ready():
	add_to_group('Landable', true)
	pass

func init(landableName):
	data = Core.landablesData.get(landableName)
	print(data)
	
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