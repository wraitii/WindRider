extends Node

enum TARGETING_MODE { KEYBOARD, FOLLOW_MOUSE }

var TargetingMode = TARGETING_MODE.KEYBOARD;

# used to 'doubletap' warp.
var last_warp_input_time = 0;

func _init():
	InputMap.add_action('player_open_galaxy_map')
	var event = InputEventKey.new()
	event.scancode = KEY_M
	InputMap.action_add_event('player_open_galaxy_map', event)

	InputMap.add_action('player_open_system_map')
	event = InputEventKey.new()
	event.scancode = KEY_L
	InputMap.action_add_event('player_open_system_map', event)

	InputMap.add_action('player_open_sector_map')
	event = InputEventKey.new()
	event.scancode = KEY_K
	InputMap.action_add_event('player_open_sector_map', event)

	InputMap.add_action('player_open_player_info')
	event = InputEventKey.new()
	event.scancode = KEY_I
	InputMap.action_add_event('player_open_player_info', event)

func _process(delta):
	var ship = Core.gameState.playerShip;
	
	if Input.is_action_just_released('switch_camera'):
		Core.gameState.currentScene.get_node('Camera').switch_mode()

	if Input.is_action_just_released('ship_reset_systems'):
		ship.dockingProcedure = null;
		ship.navSystem.reset()
		ship.targetingSystem.reset()

	if Input.is_action_just_released('ship_switch_driving_mode'):
		ship.navSystem.switch_driving_mode()

	if Input.is_action_just_released('ship_switch_controlling_mode'):
		TargetingMode = TargetingMode + 1
		if TargetingMode >= 2:
			TargetingMode = 0

	if Input.is_action_just_released("ship_activate_autopilot"):
		ship.navSystem.set_mode(ship.navSystem.MODE.MOVE)

	if Input.is_action_just_released('ship_next_target'):
		ship.targetingSystem.pick_new_target()

	if Input.is_action_just_pressed('ship_fire'):
		ship.start_firing();
	elif Input.is_action_just_released('ship_fire'):
		ship.stop_firing();

	# Can take us out of the world
	if Input.is_action_just_released('ship_dock'):
		if !ship.navSystem.has_target():
			ship.navSystem.target_closest_nav_object();
		ship.try_dock()

	if Input.is_action_just_released('warp_factor'):
		# if switching fast, switch, otherwise assume we want to reset.
		if OS.get_ticks_msec() - last_warp_input_time > 1000 and Core.gameState.warp_factor != 1:
			Core.gameState.warp_factor = 1
		else:
			Core.gameState.warp_factor += 1
			if Core.gameState.warp_factor >= len(Core.gameState.warp_factors):
				Core.gameState.warp_factor = 0
		last_warp_input_time = OS.get_ticks_msec()
		Engine.set_time_scale(Core.gameState.warp_factors[Core.gameState.warp_factor])

func moveCommandProcess():
	var commands = []

	var ship = Core.gameState.playerShip;

	# Input commands slower when warping so things remain controllable.
	var warp_multiplier = (1/Engine.get_time_scale());
	
	if Input.is_action_pressed('ship_rotate_left'):
		commands.push_back(['rotate_left', [warp_multiplier]])
	elif Input.is_action_pressed('ship_rotate_right'):
		commands.push_back(['rotate_right', [warp_multiplier]])
	elif Input.is_action_pressed('ship_rotate_roll_left'):
		commands.push_back(['roll_left', [warp_multiplier]])
	elif Input.is_action_pressed('ship_rotate_roll_right'):
		commands.push_back(['roll_right', [warp_multiplier]])

	if Input.is_action_pressed('ship_rotate_up'):
		commands.push_back(['rotate_up', [warp_multiplier]])
	elif Input.is_action_pressed('ship_rotate_down'):
		commands.push_back(['rotate_down', [warp_multiplier]])

	if Input.is_action_pressed("ship_thrust"):
		if ship.navSystem.drivingMode == ship.navSystem.DRIVING_MODE.AUTOTHRUST:
			ship.navSystem.targetSpeed = min(1.0, ship.navSystem.targetSpeed + 0.02 * warp_multiplier)
		else:
			commands.push_back(['thrust', [warp_multiplier]])
	elif Input.is_action_pressed('ship_reverse'):
		if ship.navSystem.drivingMode == ship.navSystem.DRIVING_MODE.AUTOTHRUST:
			ship.navSystem.targetSpeed = max(0.0, ship.navSystem.targetSpeed - 0.02 * warp_multiplier)
		else:
			commands.push_back(['reverse', [warp_multiplier]])

	if Input.is_action_pressed("ship_aim_towards_target"):
		commands.push_back('aim_towards_target')

	if TargetingMode == TARGETING_MODE.FOLLOW_MOUSE:
		var dir = get_viewport().get_camera().project_ray_normal(get_viewport().get_mouse_position())
		var deadzone = get_viewport().get_mouse_position();
		var zone = get_viewport().get_visible_rect().end
		var maxzone = min(zone.x, zone.y) / 3
		deadzone = deadzone-zone/2;
		deadzone.x = min(1, max(0, abs(deadzone.x)-30) / maxzone)
		deadzone.y = min(1, max(0, abs(deadzone.y)-30) / maxzone)
		commands.push_back(['follow_vector', [dir, deadzone]])

	var ret = []
	for c in commands:
		ret.push_back([Core.gameState.playerShip, c])

	ret += ship.navSystem.autothrust()
	ship.navSystem.autorailroad()

	return ret
