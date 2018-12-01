extends Node

### Society
## A society is supposed to represent a character, corporation or a government
## Basically an entity that can have an opinion on other societies and characters

const Opinion = preload('Opinion.gd')

var ID;

var opinions = {};

var outfits = [];

var credits = 0;

func init(d):
	ID = d.ID
	if 'relations' in d:
		for rel in d['relations']:
			var tgt = Core.societyData.get(rel['target']);
			var r = Opinion.new(self, tgt);
			r.core_opinion = rel['core_opinion'];
			opinions[rel['target']] = r