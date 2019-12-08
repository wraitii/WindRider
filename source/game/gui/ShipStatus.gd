extends Container

func _process(delta):
	var ship = Core.gameState.playerShip
	if !ship:
		return
	
	## TODO : ship name
	
	get_node('Shields/ShieldsBar').scale = Vector2(ship.shields / ship.stat('max_shields'),1)
	get_node('Armour/ArmourBar').scale = Vector2(ship.armour / ship.stat('max_armour'),1)
	get_node('Energy/EnergyBar').scale = Vector2(ship.energy / ship.stat('max_energy'),1)
	
	if get_node('Hyperfuel').get_child_count() != ship.stat('max_hyperfuel'):
		for child in get_node('Hyperfuel').get_children():
			get_node('Hyperfuel').remove_child(child)
		for i in range(0, floor(ship.stat('max_hyperfuel')/100.0)):
			var item = ColorRect.new()
			item.rect_min_size = Vector2(16000/ship.stat('max_hyperfuel') - 4,20)
			get_node('Hyperfuel').add_child(item)
	
	for i in range(0, floor(ship.stat('max_hyperfuel')/100.0)):
		if ship.hyperfuel >= (i+1)*100:
			get_node('Hyperfuel').get_child(i).color = Color(0,0.6,0,0.4)
		else:
			get_node('Hyperfuel').get_child(i).color = Color(0.4,0.4,0.4,0.4)
