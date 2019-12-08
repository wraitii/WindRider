extends Spatial

func init(data):
	var scene = data['scene']
	
	var graph = load('res://data/art/ships/' + scene + '.tscn')
	self.add_child(graph.instance())
	
