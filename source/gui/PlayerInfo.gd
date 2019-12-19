extends Control

func _ready():
	$"Tabs/ShipHoldView".init(Core.gameState.playerShip.hold)
	
	var st = "Credits: " + str(Core.gameState.player.credits)
	$Tabs/Player/Desc.text = st

	for t in Core.gameState.player.traits.traits:
		var trait = $Tabs/Player/TraitCtl.duplicate()
		trait.hint_tooltip = t + ' - ' + Core.gameState.player.traits.traits[t].describe()
		$Tabs/Player/Traits.add_child(trait)
		trait.show()

func _process(delta):
	if Input.is_action_just_released("default_escape_action"):
		hide()

	# TODO: check if we can be opened
	if Input.is_action_just_released('player_open_player_info'):
		show()
