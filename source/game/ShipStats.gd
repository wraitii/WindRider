extends Node

const Component = preload('Component.gd')
const WeaponSystem = preload('WeaponSystem.tscn')
const StatsHelper = preload('StatsHelper.gd')

var shipData;

var stats : StatsHelper;

func init(data):
	shipData = data

	for component in data['components']:
		_parse_component(component)
	_compute_stats()
	get_parent().set_mass(get('empty_mass'))

func get(s):
	if !(s in stats.statsCache):
		return null # not necessarily a problem
	return stats.statsCache[s]

func _parse_component(compInfo):
	var cdata = Core.dataMgr.get('ship_components/' + compInfo['ID'])
	if !cdata:
		return
	var comp = Component.new(cdata)
	self.add_child(comp)
	
	if 'weapons' in cdata:
		_create_weapons(comp, cdata);	

func _compute_stats():
	# Fetch stat item from ship & components
	var cit = []
	for c in get_children():
		for s in c.data.stats:
			cit.push_back(s)
	stats = StatsHelper.new(shipData['stats'] + cit)

func _create_weapons(comp, data):
	for weap in data['weapons']:
		var weapon = WeaponSystem.instance()
		weapon.init(comp, get_parent(), weap)
		get_parent().get_node('WeaponsSystem').add_child(weapon)