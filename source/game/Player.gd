extends Node

var playerShip setget setCurrentShip, get_current_ship

func _ready():
	setCurrentShip(get_node("/root/InGameRoot/Ship"))
	pass

func setCurrentShip(ship):
	playerShip = ship;
	playerShip.connect('got_chat', self, 'on_chat')

func get_current_ship():
	return playerShip;

func on_chat(convo, sender, chatData):
	var chat = get_node('/root/InGameRoot/Chat')
	if len(chat.text) >= 100:
		chat.text = ""
	chat.text += chatData.message + '\n'
	pass