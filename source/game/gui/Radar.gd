extends Control

const JumpZone = preload('../JumpZone.gd')
var radar = {}

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

	
	var landables = get_tree().get_nodes_in_group('Landables')
	for l in landables:
		var pixel;
		var id;
		
		if l is JumpZone:
			id = l.jumpTo;
		else: id = l.data.name
			
		if id in radar:
			pixel = radar[id]
		else:
			pixel = Polygon2D.new()
			pixel.polygon = [
				Vector2(-0.5,-0.5),
				Vector2(0.5,-0.5),
				Vector2(0.5,0.5),
				Vector2(-0.5,0.5)
			]
			pixel.scale = Vector2(3,3)
			pixel.color = Color(1, 1, 0)
			get_node('center').add_child(pixel)
			radar[id] = pixel
		var p = (l.translation - playerShip.translation)
		pixel.position = Vector2(p.x, p.z) * 0.5
