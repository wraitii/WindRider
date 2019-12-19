extends Node

class_name Utils

static func safe_push(x, key, value):
	if !(key in x):
		x[key] = []
	x[key].append(value)
	return x

static func safe_erase(x, key, value):
	if key in x:
		x[key].erase(value)

static func full_erase(x, key, value):
	assert(key in x and value in x[key])
	x[key].erase(value)
	if x[key].size() == 0:
		x.erase(key)
