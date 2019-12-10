extends Control

func _enter_tree():
	Core.gameState.player.connect('player_ship_changed', self, '_on_player_ship_change')
	_on_player_ship_change(Core.gameState.playerShip)

func _on_player_ship_change(ship):
	ship.targetingSystem.connect('target', self, '_on_target')
	ship.targetingSystem.connect('untarget', self, '_on_untarget')

var target = null;

func _on_target(target_):
	target = target_

func _on_untarget(shipID):
	target = null

func _process(delta):
	if !Core.gameState.playerShip:
		return

	# Compute the cross for aiming.
	var faraway = Core.gameState.playerShip.get_transform().xform(Vector3(0,0,-500.0))
	get_node("Firing Reticule").position = get_viewport().get_camera().unproject_position(faraway)
	
	# Compute the cross for instant firing.
	if target == null:
		return
	
	# Assume weapon speed for now
	var dir_pos = Intercept.simple_intercept(Core.gameState.playerShip, Core.outsideWorldSim.ship(target), 1000)

	if dir_pos[1] == null:
		get_node("Aim Reticule").hide()
	else:
		get_node("Aim Reticule").show()
		get_node("Aim Reticule").position = get_viewport().get_camera().unproject_position(dir_pos[1])

	