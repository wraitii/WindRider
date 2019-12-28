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
var triggers = []

func _init().('Missions', 'res://data/missions/'):
	pass

func populate():
	## Let's populate triggers
	var triggers = Core.dataMgr.get('missions/triggers/')
	print(triggers)

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
	item.init(d);
	return item;

func _on_big_time_pass(ms):
	## TODO: review temporaries
	return
