extends Node

var ship setget setCurrentShip, get_current_ship

func _ready():
	ship = Core.gameState.playerShip
	get_node('../Camera').followedShip = ship
	get_node('../VelocityRadar').set_follower(ship)
	pass

func _process(delta):
	if Input.is_action_just_released('switch_camera'):
		get_node('../Camera').switch_mode()
	if Input.is_action_just_released('ship_dock'):
		if ship.navSystem.target == null:
			ship.navSystem.target_closest_landable();
		ship.dock()

func setCurrentShip(s):
	ship = s;
	ship.connect('got_chat', self, 'on_chat')
	ship.connect('docking', self, 'on_dock')

func get_current_ship():
	return ship;

func on_chat(convo, sender, chatData):
	var chat = get_node('../Chat')
	if len(chat.text) >= 100:
		chat.text = ""
	chat.text += chatData.message + '\n'
	pass

func on_dock(dock):
	get_tree().change_scene('res://source/game/Docked.tscn')