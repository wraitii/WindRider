extends Container

func _process(delta):
	var ship = Core.gameState.playerShip
	if !ship:
		return
	
	## TODO : ship name
	
	get_node('Shields/ShieldsBar').scale = Vector2(ship.shields / ship.stat('max_shields'),1)
	get_node('Armour/ArmourBar').scale = Vector2(ship.armour / ship.stat('max_armour'),1)
	get_node('Energy/EnergyBar').scale = Vector2(ship.energy / ship.stat('max_energy'),1)