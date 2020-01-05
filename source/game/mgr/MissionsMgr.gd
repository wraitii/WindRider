extends "res://source/lib/EntityMgr.gd"

## The missions manager is in charge of holding active and potential missions
## Missions are slightly tricky because there are triggers for them to be available
## (or fire automatically), and then there is the actual missions themselves.
## However there are some data-files for missions, which aren't really handled here.

#### Indexes for fast-mission access.

## Temporary missions are created e.g. when landing on a station
## These will (usually) appear in the mission board, and will be deleted after a while.
## In GC-parlance, this is the nursery.
var temporaries = []

## Holds a list of mission triggers that may or may not create missions
var triggers = {}

func _init().('Missions', 'res://data/missions/'):
	pass

func populate():
	## Let's populate triggers
	var trigs = Core.dataMgr.get_all('missions/triggers/')
	for trigger in trigs:
		triggers[trigger] = Core.dataMgr.get(trigger)

func validation(d, _path):
	assert('provider' in d)
	return true

var counter = 0;
func _uid():
	var id = 'mission_' + str(counter) + '_' + str(OS.get_system_time_msecs());
	counter += 1
	assert(!(id in data))
	# We support creating up to 500K items in a single millisecond
	if counter > 500000:
		counter = 0
	return id

func _instance(d):
	var MissionType = load('res://source/game/missions/' + d['type'] + '.gd')
	var item = MissionType.new();
	item.ID = _uid();
	item.provider = d['provider']
	if !item.init(d):
		item.finish()
		return null
	return item;

func _on_big_time_pass(ms):
	## TODO: review temporaries
	return

#### TODO: move this to a trigger evaluator?

func _and(triggers, soc):
	for trigger in triggers:
		if 'trait' in trigger:
			if !soc.traits.has_type(trigger['trait']['type']):
				return false
	return true

func triggers_pass(triggers, soc):
	## treat as AND for now
	return _and(triggers, soc)

func can_show(trigger, giver, receiver):
	if !triggers_pass(trigger["giver"], giver):
		return false
	if !triggers_pass(trigger["receiver_to_show"], receiver):
		return false
	return true

func can_accept(trigger, receiver):
	return triggers_pass(trigger["receiver_to_accept"], receiver)

func serialize():
	var ret = {}
	for ID in data:
		if data[ID].should_serialize():
			ret[ID] = data[ID].serialize()
	return ret

func deserialize(d):
	populate()
	for ID in d:
		var MissionType = load('res://source/game/missions/' + d[ID]['type'] + '.gd')
		var item = MissionType.new();
		item.ID = ID;
		item.deserialize(d[ID])
		data[ID] = item
