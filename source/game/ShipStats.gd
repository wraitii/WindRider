extends Node

const Component = preload('Component.gd')

var shipData;

var stats = {};

func init(data):
	shipData = data

	for component in data['components']:
		_parse_component(component)
	_compute_stats()

func get(s):
	if !(s in stats):
		return null # not necessarily a problem
	return stats[s]

func _parse_component(compInfo):
	var cdata = Core.componentsData.get(compInfo['name'])
	if !cdata:
		return
	var comp = Component.new(cdata)
	
	self.add_child(comp)

func _sort_stat(a, b):
	# true if a<b
	var aa = a['order'] || 0
	var bb = b['order'] || 0
	return aa <= bb

func _get_stat_effect(stat):
	if 'name' in stat:
		return stat['name']
	if stat.size() != 1:
		return null
	return stat.keys()[0]

func _parse_stat_value(value, stat):
	match stat:
#warning-ignore:unassigned_variable
		{ 'add': var v }:
			return value + v
		_:
			if stat.size() != 1:
				print("Unrecognized pattern in value:" + str(stat))
				return value
			return value + stat.values()[0]

func _compute_stats():
	var statsList = {};

	# Fetch stat item from ship & components
	var cit = []
	for c in get_children():
		for s in c.data.stats:
			cit.push_back(s)

	var items = shipData['stats'] + cit
	for stat in items:
		var se = _get_stat_effect(stat)
		if !(se in statsList):
			statsList[se] = [];
		statsList[se].push_back(stat)

	for stat in statsList:
		statsList[stat].sort_custom(self, '_sort_stat');
		var val = 0;

		for item in statsList[stat]:
			val = _parse_stat_value(val, item);
		stats[stat] = val;
	
	print(stats)
