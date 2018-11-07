extends Node

var target = null;

var ship = null;

func _enter_tree():
	ship = get_parent();

func target_closest_landable():
	var landables = get_tree().get_nodes_in_group('Landable')
	var bestLandable = [null,null]
	for landable in landables:
		var dist = landable.translation.distance_squared_to(ship.translation)
		if bestLandable[1] == null || dist <= bestLandable[1]:
			bestLandable[0] = landable;
			bestLandable[1] = dist;
	target = bestLandable[0]