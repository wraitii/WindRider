extends Node

var ship = null;
var objective = null;

## TODO: figure this out.

func _enter_tree():
	ship = get_parent();

func _exit_tree():
	ship = null;

func random_point():
	return Vector3((randf() - 0.5) * 1000, (randf() - 0.5) * 1000, (randf() - 0.5) * 1000)

func do_ai():
	if ship == null: # probably not yet in scene
		return

	if objective == null:
		objective = random_point()
	
	ship.align_with(objective - ship.transform.origin)
	ship.thrust()
	
	if (objective - ship.transform.origin).length_squared() < 100:
		objective = random_point()
