extends Control

### Marketplace
## Allows you to buy and sell stuff.
## Combines the trade, outfit and shipyards functionality all in one.
## This is just an abstraction for what's happening on the dock.

var ownerDock;

var products = {}

func init(d):
	ownerDock = d;
	_update_products()

func _update_products():
	for socName in ownerDock.societyPresence:
		var society = Core.societyData.get(
	pass
