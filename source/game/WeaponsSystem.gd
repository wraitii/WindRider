extends Spatial

# hardpoint name ndexed by x,y,z 'hold' indices.
var hardpoints_by_hold = {}
# Indexed by hardpoint name.
var hardpoints = {};

func init():
	var ship = get_parent()
	
	if !('hardpoints' in ship.data):
		return

	for hardpoint in ship.data['hardpoints']:
		hardpoints[hardpoint] = []
		var idx = ship.data['hardpoints'][hardpoint]["pos"]
		hardpoints_by_hold[ship.hold._idx(idx[0], idx[1], idx[2])] = hardpoint

func find_hardpoint(weapon):
	assert(weapon.comp)
	assert(len(weapon.comp.holdIndices))
	for i in weapon.comp.holdIndices:
		if i in hardpoints_by_hold:
			hardpoints[hardpoints_by_hold[i]].append(weapon)
			weapon.hardpoint = hardpoints_by_hold[i]
	# Add as child to trigger timers
	add_child(weapon)

func start_firing():
	for mount in hardpoints:
		for weapon in hardpoints[mount]:
			weapon.start_firing();

func stop_firing():
	for mount in hardpoints:
		for weapon in hardpoints[mount]:
			weapon.stop_firing();
