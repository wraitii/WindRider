extends Spatial

enum MODE { MOVE, KILL, EVADE }

var ship = null;
var objective = null;

var mode = MODE.MOVE;

var evade_rand_vec

var rcast

## TODO: figure this out.
func _enter_tree():
	ship = get_parent()
	if ship == Core.gameState.playerShip:
		return

	rcast = RayCast.new()
	rcast.enabled = true
	rcast.cast_to = Vector3(0,0,-250)
	rcast.add_exception(get_parent())
	call_deferred("add_child", rcast)

func _exit_tree():
	ship = null;
	var c = get_children()
	for i in c:
		if i.get_parent():
			NodeHelpers.call_deferred("queue_delete", i)

func random_point():
	return Vector3((randf() - 0.5) * 5000, (randf() - 0.5) * 5000, (randf() - 0.5) * 5000)

func do_ai():
	if ship == null: # probably not yet in scene
		return

	var comms = get_tree().get_nodes_in_group('command_manager')[0]
	
	comms.commands += ship.autopilot.autothrust()
	ship.autopilot.autorailroad()
	
	if rcast.is_colliding() and get_parent().linear_velocity.length() > 10:
		comms.commands.append([ship, 'rotate_up'])
		return

	if objective == null:
		var behaviour = randf();
		if ship.data.ID == "Cycles" and behaviour > 1.6: # deactivated for now
			objective = weakref(Core.gameState.playerShip)
			mode = MODE.KILL
			ship.autopilot.reset()
			ship.targetingSystem.reset()
			ship.targetingSystem.target(objective.get_ref().ID)
			ship.autopilot.activate()
		else:
			objective = random_point()
			mode = MODE.MOVE

	for threatID in ship.targetingSystem.threats:
		var threat = Core.outsideWorldSim.ship(threatID)
		if mode != MODE.KILL and threat.translation.distance_to(ship.translation) < 1000:
			mode = MODE.EVADE
			objective = weakref(threat)
			_pick_random_evade_vector()
			
	if mode == MODE.MOVE:
		ship.autopilot.targetSpeed = 1
		comms.commands.append([ship, ['align_with', [objective - ship.transform.origin]]])
		if (objective - ship.transform.origin).length_squared() < 100:
			objective = null

	elif mode == MODE.EVADE:
		ship.autopilot.targetSpeed = 1
		if !objective.get_ref():
			objective = null
			return
		
		var threat = objective.get_ref()
		var dir = (ship.transform.origin - threat.translation).normalized() + evade_rand_vec
		comms.commands.append([ship, ['align_with', [dir]]])
		if (threat.translation - ship.transform.origin).length_squared() > 1500*1500:
			objective = null
		if randf() > 0.997:
			_pick_random_evade_vector()

	else:
		var target = objective.get_ref()
		if !target:
			objective = null
			return
		if (target.translation - ship.translation).length_squared() < 400*400:
			ship.start_firing()
		else:
			ship.stop_firing()

func on_collision_warning(body):
	# super dumb
	objective = null

func _pick_random_evade_vector():
	evade_rand_vec = Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5).normalized()
