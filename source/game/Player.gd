extends Node

var ship setget setCurrentShip, get_current_ship

func _process(delta):
	if Input.is_action_just_released('switch_camera'):
		Core.gameState.currentScene.get_node('Camera').switch_mode()
	if Input.is_action_just_released('ship_dock'):
		if ship.navSystem.targetNode == null:
			ship.navSystem.target_closest_landable();
		ship.try_dock()
	if Input.is_action_just_released('ship_reset_systems'):
		ship.dockingProcedure = null;
		ship.navSystem.reset()

	if Input.is_action_just_pressed('ship_fire'):
		ship.start_firing();
	elif Input.is_action_just_released('ship_fire'):
		ship.stop_firing();

func moveCommandProcess():
	var commands = []
	if Input.is_action_pressed("ship_thrust"):
		commands.push_back('thrust')
	if Input.is_action_pressed('ship_reverse'):
		commands.push_back('reverse')
	elif Input.is_action_pressed('ship_rotate_left'):
		commands.push_back('rotate_left')
	elif Input.is_action_pressed('ship_rotate_right'):
		commands.push_back('rotate_right')
	var ret = []
	for c in commands:
		ret.push_back([ship, c])
	return ret;

func setCurrentShip(s):
	ship = s;
	ship.connect('got_chat', self, 'on_chat')

func get_current_ship():
	return ship;

func on_chat(convo, sender, chatData):
	var chat = Core.gameState.currentScene.get_node('Chat')
	if len(chat.text) >= 100:
		chat.text = ""
	chat.text += chatData.message + '\n'
	pass

func on_jump(from, to):
	Core.gameState.jumpingFrom = from;
	Core.jump()
