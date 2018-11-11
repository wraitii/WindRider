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

func setCurrentShip(s):
	ship = s;
	ship.connect('got_chat', self, 'on_chat')
	ship.connect('docking', self, 'on_dock')
	ship.connect('undocking', self, 'on_undock')
	
func get_current_ship():
	return ship;

func on_chat(convo, sender, chatData):
	var chat = Core.gameState.currentScene.get_node('Chat')
	if len(chat.text) >= 100:
		chat.text = ""
	chat.text += chatData.message + '\n'
	pass

func on_dock(dock):
	Core.dock(dock)

func on_undock(a):
	Core.undock()
