extends 'res://source/game/Landable.gd'

var jumpTo = null;

func init(system):
	jumpTo = system['name'];