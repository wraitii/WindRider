extends HBoxContainer

func _enter_tree():
	Core.gameState.player.connect('player_ship_changed', self, '_on_player_ship_change')
	_on_player_ship_change(Core.gameState.playerShip)

func _on_player_ship_change(ship):
	ship.targetingSystem.connect('target', self, '_on_target')
	ship.targetingSystem.connect('untarget', self, '_on_untarget')

const TargetGUI = preload('res://source/game/gui/Target.tscn')

# ID > GUI element
var targets = {}

func _on_target(targetID):
	var target = TargetGUI.instance()
	targets[targetID] = target
	target.init(Core.outsideWorldSim.ship(targetID))
	add_child(target)

func _on_untarget(targetID):
	remove_child(targets[targetID])
	targets.erase(targetID)
