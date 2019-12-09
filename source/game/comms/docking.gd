extends "res://source/game/Communication.gd"

# Docking
## Lets sender ask for docking at receiver

enum {
	ASK_DOCKING,
	DOCKING_OK,
	DOCKING_REFUSED,
	DOCKING_NOW
}

var docking_status = null

func _init(s,r).(s,r):
	return self

class DockingChat:
	var type = null;
	func _init(t):
		type = t

func send_to_sender(message, status):
	_send_to_sender(Chat.new(message, DockingChat.new(status)))

func ask_for_docking():
	_send_to_receiver(Chat.new("May I land", DockingChat.new(ASK_DOCKING)))
	return true

func allow_docking():
	_send_to_sender(Chat.new("You may land", DockingChat.new(DOCKING_OK)))
	docking_status = DOCKING_OK
	receiver.connect('trigger_dock', self, '_on_body_entered')
	return true

func refuse_docking():
	_send_to_sender(Chat.new("You may not land", DockingChat.new(DOCKING_REFUSED)))
	docking_status = DOCKING_REFUSED
	return true;

func still_ok():
	if receiver.graphics.has_node('SlowDockArea'):
		if receiver.graphics.get_node('SlowDockArea').overlaps_body(sender):
			_do_dock()
			return true;
		_send_to_sender(Chat.new("Please come closer to docking area.", DockingChat.new(DOCKING_OK)))
		return true;

	_send_to_sender(Chat.new("Cleared for docking, approach through docking tunnel.", DockingChat.new(DOCKING_OK)))
	return true;

func dock():
	_send_to_sender(Chat.new("…Docking…", DockingChat.new(DOCKING_NOW)))
	return true;

func _on_body_entered(body):
	if body == sender:
		_do_dock()

func _do_dock():
	receiver.disconnect('trigger_dock', self, '_on_body_entered')
	call_deferred("dock")
