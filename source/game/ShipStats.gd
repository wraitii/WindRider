extends Node

const Component = preload('Component.gd')
const WeaponSystem = preload('WeaponSystem.tscn')
const StatsHelper = preload('StatsHelper.gd')

var shipData;

var stats : StatsHelper;

func init(data):
	shipData = data

	for component in data['components']:
		_add_component('ship_components/' + component['ID'])
	_compute_stats()
	get_parent().set_mass(get('mass'))

func get(s):
	if !(s in stats.statsCache):
		return null # not necessarily a problem
	return stats.statsCache[s]

func get_components(comp_id):
	var components = get_children()
	var out = []
	for component in components:
		if component.ID == comp_id:
			out.append(component)
	return out

func remove_component(comp_id):
	var components = get_children()
	for component in components:
		if component.ID == comp_id:
			self.remove_child(component)
			return

func add_component(comp_id):
	_add_component(comp_id)
	_compute_stats()
	
func _add_component(comp_id):
	var comp = Component.new(comp_id)
	self.add_child(comp)

	var cdata = Core.dataMgr.get(comp_id)	
	if 'weapons' in cdata:
		_create_weapons(comp, cdata);

func _compute_stats():
	# Fetch stat item from ship & components
	var cit = []
	for c in get_children():
		for s in Core.dataMgr.get(c.ID).stats:
			cit.push_back(s)
	stats = StatsHelper.new(shipData['stats'] + cit)

func _create_weapons(comp, data):
	for weap in data['weapons']:
		var weapon = WeaponSystem.instance()
		weapon.init(comp, get_parent(), weap)
		get_parent().get_node('WeaponsSystem').add_child(weapon)
