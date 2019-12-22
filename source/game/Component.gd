extends Spatial

const WeaponSystem = preload('WeaponSystem.tscn')

var ID;
var _raw;

var holdIndices = [];
var weaponSystems = [];

# Default -> can store 100 per cell
const DEFAULT_STORAGE_VOLUME = 100;

func init(data):
	ID = data.ID
	_raw = data;
	return self

func _get(prop):
	if prop == 'holdIndices':
		return holdIndices
	if prop == 'weaponSystems':
		return weaponSystems
	return _raw.get(prop)

func serialize():
	return {
		"ID": ID,
		"_raw": _raw,
		"holdIndices": holdIndices
	}

func deserialize(data):
	for prop in data:
		if prop in ['ID','_raw','holdIndices']:
			set(prop, data[prop])
	for h in holdIndices:
		var ship = get_parent().get_parent()
		ship.hold.holdContent[h].components.append(self)
	create_weapons()

func create_weapons():
	if !('weapons' in _raw):
		return
	for weap in _raw['weapons']:
		var weapon = WeaponSystem.instance()
		weaponSystems.append(weapon)
		weapon.init(self, get_parent().get_parent(), weap)
		get_parent().get_parent().get_node('WeaponsSystem').find_hardpoint(weapon)

const Hold = preload("ShipHold.gd")

# Return the component as a resource type
static func ress(data):
	var vol = DEFAULT_STORAGE_VOLUME

	if 'max_per_hold' in data:
		# Only one weapon per hardmount (for now?)
		if data['hold_type'] and data['hold_type'] == "WEAPON":
			assert(data['max_per_hold'] == 1)
		vol = int(Hold.MAX_HOLD_VOL / data['max_per_hold'])
	
	return Hold.HoldItem.new(data.ID, Hold.HoldItem.TYPE.COMPONENT, vol, 1)
