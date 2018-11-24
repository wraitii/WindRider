extends Node

const Component = preload('Component.gd')
const WeaponSystem = preload('WeaponSystem.tscn')

var shipData;

var stats = {};

func init(data):
	shipData = data

	for component in data['components']:
		_parse_component(component)
	_compute_stats()
	get_parent().set_mass(stats['empty_mass'])

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
	
	if 'weapons' in cdata:
		_create_weapons(comp, cdata);	

func _stat_order_value(a):
	if 'order' in a:
		return a['order']
	return 0;
	
func _sort_stat(a, b):
	# true if a<b
	var aa = _stat_order_value(a)
	var bb = _stat_order_value(b)
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

func _create_weapons(comp, data):
	for weap in data['weapons']:
		var weapon = WeaponSystem.instance()
		weapon.init(comp, get_parent(), weap)
		get_parent().get_node('WeaponsSystem').add_child(weapon)