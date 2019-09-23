extends Node


# Achtung: this is a reference to the actual node
var targetNode = null;

var ship = null;

func _enter_tree():
	ship = get_parent();

func _exit_tree():
	targetNode = null;

func reset():
	targetNode = null;

func target_closest_nav_object():
	var landables = get_tree().get_nodes_in_group('Landables') + get_tree().get_nodes_in_group('JumpZones')
	var bestLandable = [null,null]
	for landable in landables:
		var dist = landable.translation.distance_squared_to(ship.translation)
		if bestLandable[1] == null || dist <= bestLandable[1]:
			bestLandable[0] = landable;
			bestLandable[1] = dist;
	targetNode = bestLandable[0]
