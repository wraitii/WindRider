extends Node

const Component = preload('Component.gd')
const WeaponSystem = preload('WeaponSystem.tscn')
const StatsHelper = preload('StatsHelper.gd')

var stats : StatsHelper;

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

#func remove_component(comp_id):
#	var components = get_children()
#	for component in components:
#		if component.ID == comp_id:
#			self.remove_child(component)
#			return

func install(component):
	self.add_child(component)
	if 'weapons' in component:
		_create_weapons(component);

func _create_weapons(comp):
	for weap in comp['weapons']:
		var weapon = WeaponSystem.instance()
		comp.weaponSystem = weapon
		weapon.init(comp, get_parent(), weap)
		get_parent().get_node('WeaponsSystem').find_hardpoint(weapon)

func _compute_stats():
	# Fetch stat item from ship & components
	var cit = []
	for c in get_children():
		for s in Core.dataMgr.get("ship_components/" + c.ID).stats:
			cit.push_back(s)
	stats = StatsHelper.new(get_parent().data['stats'] + cit)
	get_parent().set_mass(get('mass'))
