extends "res://source/game/Communication.gd"

# Docking
## Lets sender ask for docking at receiver

enum Types {
	ASK_DOCKING,
	DOCKING_OK,
	DOCKING_REFUSED,
	DOCKING_TRY,
	DOCKING_TOO_FAR,
	DOCKING_TOO_FAST,
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
	return true

func refuse_docking():
	_send_to_sender(Chat.new("You may not land", DockingChat.new(DOCKING_REFUSED)))
	docking_status = DOCKING_REFUSED
	return true;

func try_docking():
	_send_to_receiver(Chat.new("Now docking", DockingChat.new(DOCKING_TRY)))
	return true;

func too_far_away():
	_send_to_sender(Chat.new("You are too far away to dock", DockingChat.new(DOCKING_TOO_FAR)))
	return true;

func dock():
	_send_to_sender(Chat.new("…Docking…", DockingChat.new(DOCKING_NOW)))
	return true;