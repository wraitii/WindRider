extends Control

const JumpZone = preload('../JumpZone.gd')
var radar = {}

func _create_pixel(size, color):
	var pixel = Polygon2D.new()
	pixel.polygon = [
		Vector2(-0.5,-0.5),
		Vector2(0.5,-0.5),
		Vector2(0.5,0.5),
		Vector2(-0.5,0.5)
	]
	pixel.scale = Vector2(size, size)
	pixel.color = color
	return pixel

func _process(delta):
	var playerShip = Core.gameState.playerShip
	if !playerShip:
		return;
	
	## TODO: Handle rotations of the ship in Follow mode
	
	var velocity = playerShip.get_linear_velocity()
	velocity = Vector2(velocity.x, -velocity.z);
	var angle = velocity.normalized().angle_to(Vector2(1,0))
	get_node('center/movementArrow').rotation = angle
	var scaleR = playerShip.get_linear_velocity().length() / playerShip.stat('max_speed');
	get_node('center/movementArrow').scale = Vector2(scaleR, scaleR)
	
	var items = get_tree().get_nodes_in_group('Landables')
	for l in items:
		if !(l.name in radar):
			radar[l.name] = _create_pixel(5, Color(1,1,0))
			get_node('center').add_child(radar[l.name])
		var p = (l.position - playerShip.translation)
		radar[l.name].position = Vector2(p.x, p.z) * 0.005

	items = get_tree().get_nodes_in_group('JumpZones')
	for l in items:
		if !(l.name in radar):
			radar[l.name] = _create_pixel(5, Color(1,0,1))
			get_node('center').add_child(radar[l.name])
		var p = (l.translation - playerShip.translation)
		radar[l.name].position = Vector2(p.x, p.z) * 0.005

	items = get_tree().get_nodes_in_group('sector_ships')
	for l in items:
		if !(l.name in radar):
			radar[l.name] = _create_pixel(2, Color(0,1,1))
			get_node('center').add_child(radar[l.name])
		var p = (l.translation - playerShip.translation)
		radar[l.name].position = Vector2(p.x, p.z) * 0.005
