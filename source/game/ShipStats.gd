extends Node

const Component = preload('Component.gd')
const StatsHelper = preload('StatsHelper.gd')

var stats : StatsHelper;

# Key -> []
var installedComps = {}

func serialize():
	var ret = []
	for c in get_children():
		ret.append(c.serialize())
	return ret

func deserialize(data):
	for c in data:
		var comp = Component.new()
		self.add_child(comp)
		comp.deserialize(c)
		Utils.safe_push(installedComps, comp.ID, comp)
	_compute_stats()

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
	Utils.safe_push(installedComps, component.ID, component)
	component.create_weapons()

# Called with comp already removed from installedComps so no need to handle here.
func uninstall(comp):
	remove_child(comp)
	for weapon in comp.weaponSystems:
		get_parent().weaponsSystem.remove_weapon(weapon)
		NodeHelpers.queue_delete(weapon)
	NodeHelpers.queue_delete(comp)

func _compute_stats():
	# Fetch stat item from ship & components
	var cit = []
	for c in get_children():
		for s in Core.dataMgr.get("ship_components/" + c.ID).stats:
			cit.push_back(s)
	stats = StatsHelper.new(get_parent().data['stats'] + cit)
	get_parent().set_mass(get('mass'))
