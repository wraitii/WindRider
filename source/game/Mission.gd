extends Reference

## Mission-data holder, similar to Nova or Endless Sky missions.
## These hold all narratives.

var type = "GenericMission"

# Auto-generated
var ID

# Used to show in the mission board and the player ongoing missions.
var mission_title = "Generic Mission"

# Society that offers the mission
var provider = null setget set_provider, get_provider

func set_provider(p):
	p.providing_missions.append(self)
	provider = p

func get_provider():
	return provider

# Character (! society) carrying the mission out.
var custodian = null setget set_custodian, get_custodian

func set_custodian(c):
	if c != null:
		c.ongoing_missions.append(self)
	elif custodian != null:
		custodian.ongoing_missions.erase(self)
	custodian = c

func get_custodian():
	return custodian

## Not intended to be overloaded, or at least parent must be called at the end.
func finish():
	if custodian:
		custodian.ongoing_missions.erase(self)
	provider.providing_missions.erase(self)
	Core.missionsMgr.call_deferred("_unregister", self)

#### These are intended to be overloaded

func init(_data):
	return

func on_accept(parentScene):
	start()

func start():
	pass

func should_serialize():
	return true

func serialize():
	var ret = {
		'ID': ID,
		'type': type,
		'provider': provider.ID
	}
	if custodian != null:
		ret['custodian'] = custodian.ID
	return ret

func deserialize(d):
	ID = d['ID']
	type = d['type']
	if 'custodian' in d:
		set_custodian(Core.societyMgr.get(d['custodian']))
	set_provider(Core.societyMgr.get(d['provider']))
