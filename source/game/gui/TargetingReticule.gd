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
	var faraway = Core.gameState.playerShip.get_transform().xform(Vector3(0,0,-5000.0))
	var closer = Core.gameState.playerShip.get_transform().xform(Vector3(0,0,-150.0))
	var fr = $"Firing Reticule/Line"
	fr.points[0] = get_viewport().get_camera().unproject_position(faraway)
	fr.points[1] = get_viewport().get_camera().unproject_position(closer)
	
	# Compute the cross for instant firing.
	if target == null:
		get_node("Aim Reticule").hide()
		return
	
	# Assume weapon speed for now
	var dir_pos = Intercept.simple_intercept(Core.gameState.playerShip.translation, Core.outsideWorldSim.ship(target), 500)

	if dir_pos[1] == null:
		get_node("Aim Reticule").hide()
	else:
		get_node("Aim Reticule").show()
		get_node("Aim Reticule").position = get_viewport().get_camera().unproject_position(dir_pos[1])

	
