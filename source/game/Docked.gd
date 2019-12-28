extends Panel

var landable

const traitIcn = preload('res://source/graphics/TraitCtl.tscn')

func _enter_tree():
	landable = Core.landablesMgr.get(Core.gameState.playerShip.dockedAt);
	$LandableName.text = landable.ID
	_check_hyperfuel();
	
	var admin = landable.administrator
	$GeneralInfo.text = str(admin.get_opinion(Core.gameState.player))

	for trait in landable.administrator.traits.traits:
		var tctl = traitIcn.instance()
		tctl.visible = true
		$Traits.add_child(tctl)
		tctl.hint_tooltip = landable.administrator.traits.traits[trait].describe()

	$Submenus/Marketplace.init(landable)
	$Submenus/Marketplace.connect('close', self, 'on_marketplace_closed')
	
	$Submenus/CommMarket.init(landable)

	$Submenus/MissionBoard.init(landable)

func _on_Undock_pressed():
	Core.gameState.playerShip.undock()

func _check_hyperfuel():
	if Core.gameState.playerShip.hyperfuel == Core.gameState.playerShip.stat('max_hyperfuel'):
		$RBCon/Refuel.disabled = true

func _on_Refuel_pressed():
	Core.gameState.playerShip.hyperfuel = Core.gameState.playerShip.stat('max_hyperfuel')
	_check_hyperfuel();

func _on_MarketplaceBtn_pressed():
	$Submenus/Marketplace.visible = true

func on_marketplace_closed():
	$Submenus/Marketplace.visible = false

func _on_CommoditiesBtn_pressed():
	$Submenus/CommMarket.visible = true

func _on_MissionsBtn_pressed():
	$Submenus/MissionBoard.visible = true
