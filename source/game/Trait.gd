extends Node

### Trait
## Holds information about the "personality" of a character/society.
## Somewhat similar to CKII traits in functionality.

var type : String;
# Traits have an ID that is sort of self-assigned, but may generically have a name
var traitName : String;
var parentSociety : String;

# Return a human-readable string narrating the trait
func describe():
	return traitName

func load_from_data(_data):
	return

# Traits can have an impact on stats by returning a list of stat-modifier
func get_stats_effects():
	return []

func should_serialize():
	return false

func serialize():
	return {}

func deserialize(d):
	return

