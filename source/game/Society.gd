extends Node

### Society
## A society is supposed to represent a character, corporation or a government
## Basically an entity that can have an opinion on other societies and characters

const Opinion = preload('Opinion.gd')
const TraitsMgr = preload('TraitsManager.gd')

var ID;
var type;
var _raw;

var opinions = {};
var outfits = [];
var credits = 10000;

var traits

func init(d):
	ID = d.ID
	type = d.type
	_raw = d
	traits = TraitsMgr.new(ID)
	if 'relations' in d:
		for rel in d['relations']:
			var tgt = Core.societyData.get(rel['target']);
			var r = Opinion.new(self, tgt);
			r.core_opinion = rel['core_opinion'];
			opinions[rel['target']] = r

func get_opinion(target):
	return 0

func serialize():
	var ret = {}
	ret._raw = _raw
	ret.type = type
	ret.credits = credits
	ret.opinions_ = {}
	for op in opinions:
		ret.opinions_[op] = opinions[op].serialize()
	# no need to serialize outfits atm
	
	ret.traits = traits.serialize()

	return ret

func deserialize(data):
	for prop in data:
		if prop in self:
			set(prop, data[prop])
	traits = TraitsMgr.new(ID)
	traits.deserialize(data.traits)
	for op in data.opinions_:
		opinions[op] = Opinion.deserialize(data.opinions[op])
