extends Node



func _process(delta):
	var ship = Core.gameState.playerShip;
	
	if Input.is_action_just_released('switch_camera'):
		Core.gameState.currentScene.get_node('Camera').switch_mode()
	if Input.is_action_just_released('ship_dock'):
		if ship.navSystem.targetNode == null:
			ship.navSystem.target_closest_nav_object();
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

	# commands related to rotation: not independent.
	if Input.is_action_pressed("ship_aim_towards_target"):
		commands.push_back('aim_towards_target')
	elif Input.is_action_pressed('ship_reverse'):
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
		ret.push_back([Core.gameState.playerShip, c])
	return ret;
