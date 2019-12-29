var statsList = {}

var statsCache = {}

func _init(specs):
	_compute_stats(specs)

func _get(key):
	if key == 'statsList':
		return statsList
	if key == 'statsCache':
		return statsCache
	
	return statsCache[key]

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
		{ 'add': var v }:
			return value + v
		_:
			if stat.size() != 1:
				print("Unrecognized pattern in value:" + str(stat))
				return value
			return value + stat.values()[0]

func _compute_stats(specs):
	statsList = {};
	statsCache = {};

	for stat in specs:
		var se = _get_stat_effect(stat)
		if !(se in statsList):
			statsList[se] = [];
		statsList[se].push_back(stat)

	for stat in statsList:
		statsList[stat].sort_custom(self, '_sort_stat');
		var val = 0;

		for item in statsList[stat]:
			val = _parse_stat_value(val, item);
		statsCache[stat] = val;
