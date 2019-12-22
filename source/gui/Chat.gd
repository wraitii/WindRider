extends ScrollContainer

func _enter_tree():
	Core.gameState.playerShip.connect('add_chat_message', self, 'add_message') 

func add_message(text):
	var mess = Label.new()
	mess.text = text;
	get_node('chats').add_child(mess);
	get_node('chats').move_child(mess,0)
