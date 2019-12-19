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
	
	if !system.get_ref():
		get_node('Targeting').text = 'Nav systems offline';
		return
	
	if !len(system.get_ref().navTargetsIDs):
		get_node('Targeting').text = 'No nav target';
		return
	
	var targetName = ""
	var target = system.get_ref().navTargetsIDs[0];
	if target.type == target.TARGET_TYPE.JUMPZONE:
		targetName = "JumpZone to " + str(target.ID)
	else:
		targetName = target.ID
	get_node('Targeting').text = 'Targeting: ' + targetName;
