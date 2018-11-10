extends Node

func parse_input():
	var commands = []
	
	var player = get_node('../../Player')
	if !player:
		return
	
	var ship = player.get_current_ship()
	if !ship:
		return
	
	if Input.is_action_pressed("ship_thrust"):
		commands.push_back('thrust')
	if Input.is_action_pressed('ship_reverse'):
		commands.push_back('reverse')
	elif Input.is_action_pressed('ship_rotate_left'):
		commands.push_back('rotate_left')
	elif Input.is_action_pressed('ship_rotate_right'):
		commands.push_back('rotate_right')
	
	var ret = []
	for comm in commands:
		ret.push_back([ship, comm])
	return ret