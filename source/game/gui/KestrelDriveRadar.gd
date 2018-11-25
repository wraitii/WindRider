extends Container

func _process(delta):
	var ship = Core.gameState.playerShip
	if !ship:
		return
	
	var height = ship.translation.y
	
	get_node('Ship').position = Vector2(30, 50 - height)