extends Container

var landable

func init(l):
	Core.gameState.save_game();
	landable = l;
	get_node('PlanetName').text = landable.ID
	_check_hyperfuel();
	
	$Submenus/Marketplace.init(landable)
	$Submenus/Marketplace.connect('close', self, 'on_marketplace_closed')
	
	var admin = landable.administrator
	get_node('GeneralInfo').text = str(admin.get_opinion(Core.gameState.player))

func _on_Undock_pressed():
	Core.gameState.playerShip._do_undock()

func _check_hyperfuel():
	if Core.gameState.playerShip.hyperfuel == Core.gameState.playerShip.stat('max_hyperfuel'):
		get_node('Refuel').disabled = true

func _on_Refuel_pressed():
	Core.gameState.playerShip.hyperfuel = Core.gameState.playerShip.stat('max_hyperfuel')
	_check_hyperfuel();

func _on_MarketplaceBtn_pressed():
	$Submenus/Marketplace.visible = true

func on_marketplace_closed():
	$Submenus/Marketplace.visible = false

func _on_CommoditiesBtn_pressed():
	$Submenus/CommMarket.visible = true
