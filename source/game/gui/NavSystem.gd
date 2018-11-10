extends Container

var navSystem = null;

func init(n):
	navSystem = n;

func _process(delta):
	if !navSystem:
		get_node('Targeting').text = 'Nav systems offline';
		return
	if !navSystem.targetNode:
		get_node('Targeting').text = 'No nav target';
		return
	get_node('Targeting').text = 'Targeting: ' + navSystem.targetNode.name;

