extends Container

var landableData

func init(l):
	Core.gameState.save_game();
	landableData = l;
	get_node('PlanetName').text = landableData.ID
	_check_hyperfuel();
	
	get_node('Marketplace').init(Core.landablesMgr.get(landableData.ID))
	get_node('Marketplace').connect('close', self, 'on_marketplace_closed')

func _on_Undock_pressed():
	Core.gameState.playerShip._do_undock()

func _check_hyperfuel():
	if Core.gameState.playerShip.hyperfuel == Core.gameState.playerShip.stat('max_hyperfuel'):
		get_node('Refuel').disabled = true

func _on_Refuel_pressed():
	Core.gameState.playerShip.hyperfuel = Core.gameState.playerShip.stat('max_hyperfuel')
	_check_hyperfuel();

func _on_MarketplaceBtn_pressed():
	get_node('Marketplace').visible = true

func on_marketplace_closed():
	get_node('Marketplace').visible = false
