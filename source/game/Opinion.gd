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

func serialize():
	return {
		'holder': holder,
		'target': target
	}

static func deserialize(data):
	# Workaround, see https://github.com/godotengine/godot/issues/27491
	var op = load('.').new()
	for prop in data:
		if prop in op:
			op.set(prop, data[prop])
	return op
