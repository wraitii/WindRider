extends Node

func parse_input():
	var commands = []
	
	var player = get_node('/root/InGameRoot/Player')
	if !player:
		return
	
	var ship = player.get_current_ship()
	if !ship:
		return
	
	if Input.is_action_pressed("ship_thrust"):
		commands.push_back('thrust')
	if Input.is_action_pressed('ship_rotate_left'):
		commands.push_back('rotate_left')
	if Input.is_action_pressed('ship_rotate_right'):
		commands.push_back('rotate_right')

	if Input.is_action_just_released('ship_dock'):
		commands.push_back('dock')
	
	var ret = []
	for comm in commands:
		ret.push_back([ship, comm])
	return ret