extends Control

var may_hide = true setget set_may_hide, get_may_hide

func set_may_hide(v):
	$CloseMap.visible = v
	may_hide = v

func get_may_hide():
	return may_hide

func _ready():
	get_node("ViewportContainer/Viewport/SystemMap").connect("sector_selected", self, "on_sector_selected")

func _input(event):
	if visible and may_hide and event.is_action_released("default_escape_action"):
		hide()
		accept_event()

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
