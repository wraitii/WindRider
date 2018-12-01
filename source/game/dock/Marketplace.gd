extends Control

### Marketplace
## Allows you to buy and sell stuff.
## Combines the trade, outfit and shipyards functionality all in one.
## This is just an abstraction for what's happening on the dock.

signal close();

var ownerDock;

var products = {}

func setup_listeners():
	get_node('Close').connect('pressed', self, 'on_close');

func init(d):
	ownerDock = d;
	_update_products()
	setup_listeners()

func _update_products():
	for socName in ownerDock.societyPresence:
		var society = Core.societyMgr.get(socName)
		for k in society.outfits:
			var outfit = Core.dataMgr.get(k)
			print(outfit['name'])
	pass

func on_close():
	emit_signal('close');