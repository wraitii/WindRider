extends Control

func _ready():
	get_node("ViewportContainer/Viewport/SystemMap").connect("sector_selected", self, "on_sector_selected")

func _process(delta):
	# TODO: check if we can be opened
	if Input.is_action_just_released('player_open_system_map'):
		# force a refresh
		var n = get_node("ViewportContainer/Viewport/SystemMap")
		if Core.gameState.playerShip:
			var s = Core.sectorsMgr.get(Core.gameState.playerShip.currentSector).system
			n.init(s)
			show()

func _on_CloseMap_pressed():
	hide()

func on_sector_selected(sectorID):
	pass
