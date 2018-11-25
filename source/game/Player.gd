extends Node

var ship setget set_current_ship, get_current_ship

signal player_ship_changed(ship)

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

	if Input.is_action_just_released('ship_next_target'):
		ship.targetingSystem.pick_new_target()

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
	elif Input.is_action_pressed('ship_rotate_left_small'):
		commands.push_back('rotate_left_small')
	elif Input.is_action_pressed('ship_rotate_right_small'):
		commands.push_back('rotate_right_small')
	elif Input.is_action_pressed('ship_rotate_left'):
		commands.push_back('rotate_left')
	elif Input.is_action_pressed('ship_rotate_right'):
		commands.push_back('rotate_right')
	var ret = []
	for c in commands:
		ret.push_back([ship, c])
	return ret;

func set_current_ship(s):
	ship = s;
	Core.gameState.playerShip = s;
	emit_signal('player_ship_changed', ship)
	ship.connect('got_chat', self, 'on_chat')
	ship.targetingSystem.connect('lost_target', self, 'on_lost_target')

func get_current_ship():
	return ship;

func on_chat(convo, sender, chatData):
	var chat = Core.gameState.currentScene.get_node('Chat')
	if len(chat.text) >= 100:
		chat.text = ""
	chat.text += chatData.message + '\n'
	pass

func on_lost_target(target):
	var chat = Core.gameState.currentScene.get_node('Chat')
	if len(chat.text) >= 100:
		chat.text = ""
	chat.text += 'Target lost.' + '\n'
	pass
