extends Area

func _ready():
	pass

const Docking = preload('res://source/game/comms/docking.gd')

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
	
	convo.dock()