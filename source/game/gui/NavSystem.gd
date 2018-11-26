extends Control

var system = null;

func _enter_tree():
	Core.gameState.player.connect('player_ship_changed', self, '_on_player_ship_change')
	_on_player_ship_change(Core.gameState.playerShip)

func _on_player_ship_change(ship):
	system = weakref(ship.navSystem);

func _process(delta):
	get_node('CurrentSystem').text = 'In ' + Core.gameState.playerShip.currentSystem;
	
	if !system.get_ref():
		get_node('Targeting').text = 'Nav systems offline';
		return
	if !system.get_ref().targetNode:
		get_node('Targeting').text = 'No nav target';
		return
	get_node('Targeting').text = 'Targeting: ' + system.get_ref().targetNode.ID;

