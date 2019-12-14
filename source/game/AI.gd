extends Node

enum MODE { MOVE, KILL }

var ship = null;
var objective = null;

var mode = MODE.MOVE;

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
		var behaviour = randf();
		if ship.data.ID == "Cycles" and behaviour > 0.6:
			print("kill")
			objective = weakref(Core.gameState.playerShip)
			mode = MODE.KILL
			ship.navSystem.reset()
			ship.targetingSystem.reset()
			ship.targetingSystem.target(objective.get_ref().ID)
			ship.navSystem.activate()
		else:
			objective = random_point()
			mode = MODE.MOVE

	if mode == MODE.MOVE:
		ship.align_with(objective - ship.transform.origin)
		ship.thrust()
	
		if (objective - ship.transform.origin).length_squared() < 100:
			objective = random_point()
	else:
		var target = objective.get_ref()
		if !target:
			objective = null
			return
		if (target.translation - ship.translation).length_squared() < 400*400:
			ship.start_firing()
		else:
			ship.stop_firing()
