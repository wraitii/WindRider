extends Control

var scale = 50

var items = {}

const mat_def = preload('Radar/Default.tres')
const mat_targ = preload('Radar/Targeted.tres')
const mat_threat = preload('Radar/Threat.tres')

func _process(delta):
	var playerShip = Core.gameState.playerShip
	if !playerShip:
		return

	var f = playerShip.transform.xform(Vector3(0, 2*scale, 20*scale))
	var u = playerShip.transform.xform(Vector3(0, 2*scale + 1, 20*scale)) - f
	$VPC/VP/Camera.look_at_from_position(f/scale, playerShip.translation/scale, u)
	
	$VPC/VP/XZ.translation = playerShip.translation/scale
	$VPC/VP/XZ.rotation = playerShip.rotation

	for ship in get_tree().get_nodes_in_group('sector_ships'):
		if ship == playerShip:
			continue
		if !(ship.ID in items):
			items[ship.ID] = $VPC/VP/Ship.duplicate()
			items[ship.ID].visible = true
			$VPC/VP.add_child(items[ship.ID])
			ship.connect('tree_exiting', self, "_on_exit", [ship.ID])
		
		items[ship.ID].get_node('dot').translation = ship.translation/scale
		items[ship.ID].get_node('dot').rotation = ship.rotation
		
		# Material overrides
		var system = Core.gameState.playerShip.targetingSystem
		if ship.ID in Core.gameState.playerShip.targetingSystem.targets:
			if items[ship.ID].get_node('dot/dot').material != mat_targ:
				items[ship.ID].get_node('dot/dot').material = mat_targ
		elif ship.ID in Core.gameState.playerShip.targetingSystem.threats:
			if items[ship.ID].get_node('dot/dot').material != mat_threat:
				items[ship.ID].get_node('dot/dot').material = mat_threat
		elif items[ship.ID].get_node('dot/dot').material != mat_def:
			items[ship.ID].get_node('dot/dot').material = mat_def
		
		var p = Plane(u, 0)
		var o = u
		var pt = p.intersects_ray(ship.translation/scale - playerShip.translation/scale, -u)
		if !pt:
			o = -u
			pt = p.intersects_ray(ship.translation/scale - playerShip.translation/scale, u)
		if pt:
			items[ship.ID].get_node('point').show()
			items[ship.ID].get_node('point').translation = pt + playerShip.translation/scale
			var to = pt + o + playerShip.translation/scale
			var up = Vector3(0,1,0)
			if up.cross(to - pt - playerShip.translation/scale).is_equal_approx(Vector3()):
				up = Vector3(1,0,0)
			items[ship.ID].get_node('point').look_at(to, up)
			var d = (ship.translation/scale - pt - playerShip.translation/scale).length()
			items[ship.ID].get_node('point').get_node('point').set_scale(Vector3(1,1, d))
			items[ship.ID].get_node('point').get_node('point').translation = Vector3(0,0,-d/2)
		else:
			items[ship.ID].get_node('point').hide()

func _on_exit(ID):
	$VPC/VP.remove_child(items[ID])
	items.erase(ID)
