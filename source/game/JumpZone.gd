extends 'res://source/game/Landable.gd'

var jumpTo = null;
var direction;

func init(system):
	jumpTo = system['name'];

func deliver(obj):
	var target = -direction
	var up = Vector3(0,1,0)
	if target == up:
		up = Vector3(1,0,0)
	obj.look_at_from_position(translation, target, up)
	print('delivering')
	print_tree()
	get_node('/root').print_tree()
	get_parent().get_parent().add_child(obj)