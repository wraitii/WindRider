extends Node

### Opinion
## Keeps all events and current status
## related to the relations between any two entities in-game

var holder;
var target;

var core_opinion;

func _init(h, t):
	holder = h;
	target = t;