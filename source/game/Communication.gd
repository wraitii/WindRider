extends Node

## Communication
## Manages communications between any 2 entities
## The purpose of this class is to be inherited
## It should manage its own state - the state of the conversation
## And acts as a signal-passer

signal chat_sender(convo, receiver, chatData)
signal chat_receiver(convo, sender, chatData)

# just for convention because this is really two-ways
var sender = null setget set_sender, get_sender;
var receiver = null setget set_receiver, get_receiver;

var communicationType = "default"

var chats = []

class Chat:
	func _init(m,d):
		message = m
		data = d
	var message = ""
	var data = null

func _init(s,r):
	set_sender(s)
	set_receiver(r)

func set_sender(s):
	sender = s
	self.connect('chat_sender', sender, 'on_received_chat')
	
func get_sender():
	return sender

func set_receiver(r):
	receiver = r
	self.connect('chat_receiver', receiver, 'on_received_chat')

func get_receiver():
	return receiver

func _send_to_sender(chat):
	chats.push_back([sender, chat])
	emit_signal("chat_sender", self, receiver, chat)
	pass

func _send_to_receiver(chat):
	chats.push_back([receiver, chat])
	emit_signal("chat_receiver", self, sender, chat)
	pass
