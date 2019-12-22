extends Control

var system = null;

func _enter_tree():
	Core.gameState.player.connect('player_ship_changed', self, '_on_player_ship_change')
	_on_player_ship_change(Core.gameState.playerShip)
	_must_update()

func _on_player_ship_change(ship):
	system = weakref(ship.navSystem);
	system.get_ref().connect('navsystem_target_change', self ,'_must_update')

func _must_update():
	if !Core.gameState.playerShip:
		return

	get_node('CurrentSector').text = 'In ' + Core.gameState.playerShip.currentSector;
	
	var sys = system.get_ref()
	
	if !sys:
		get_node('Targeting').text = 'Nav systems offline';
		return
	
	if !sys.has_target():
		get_node('Targeting').text = 'No nav target';
		return
	
	var targetName = ""
	var target = sys.get_final_target()
	targetName = _describe(target)

	var waypoint = sys.get_active_target()
	if waypoint != target:
		targetName += "\nWPT " + _describe(waypoint)
	get_node('Targeting').text = 'Targeting: ' + targetName;

func _describe(target):
	if target.type == target.TARGET_TYPE.JUMPZONE:
		return "JumpZone to " + str(target.ID)
	elif target.type == target.TARGET_TYPE.SECTOR:
		var text = target.ID + " Sector"
		text += '\n' + Core.systemsMgr.get(target.nodeRef.system).ID
		return text
	else:
		return target.ID
