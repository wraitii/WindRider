extends Control

var scale = 50

var items = {}

func _process(delta):
	var playerShip = Core.gameState.playerShip
	if !playerShip:
		return

	var f = playerShip.transform.xform(Vector3(0, 1*scale, 10*scale))
	var u = playerShip.transform.xform(Vector3(0, 1*scale + 1, 10*scale)) - f
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
		
		var p = Plane(u, 0)
		var o = u
		var pt = p.intersects_ray(ship.translation/scale - playerShip.translation/scale, -u)
		if !pt:
			o = -u
			pt = p.intersects_ray(ship.translation/scale - playerShip.translation/scale, u)
		if pt:
			items[ship.ID].get_node('point').show()
			items[ship.ID].get_node('point').translation = pt + playerShip.translation/scale
			items[ship.ID].get_node('point').look_at(pt + o + playerShip.translation/scale, Vector3(0,1,0))
			var d = (ship.translation/scale - pt - playerShip.translation/scale).length()
			items[ship.ID].get_node('point').get_node('point').set_scale(Vector3(1,1, d))
			items[ship.ID].get_node('point').get_node('point').translation = Vector3(0,0,-d/2)
		else:
			items[ship.ID].get_node('point').hide()

func _on_exit(ID):
	$VPC/VP.remove_child(items[ID])
	items.erase(ID)
