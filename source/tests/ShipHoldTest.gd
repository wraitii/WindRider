extends Label

const SH = preload('res://source/game/ShipHold.gd')

func _pr(x):
	print(x)
	text += str(x) + '\n'

func _ready():
	var data = {
		"hold" : [
			[
				[0,1,1,0],
				 [0,1,0,0],
				[1,0,2,1]
			]
		]
	}
	var hold = SH.new()
	hold.init(data)
	
	$ShipHoldView.init(hold)
	
	var hhit = hold.HoldItem.TYPE;
	
	var ress = hold.HoldItem.new("Test_A", hhit.COMMODITY)
	var cs = hold.can_store(ress)
	assert(!cs[0]) # can't store 0 amount.
	ress.amount = 1
	cs = hold.can_store(ress)
	_pr(cs)
	assert(cs[0])
	hold.store(ress, cs[1])
	_pr(hold.holdContent)
	
	ress = hold.HoldItem.new("Test_B", hhit.COMMODITY, 25, 4)
	cs = hold.can_store(ress)
	_pr(cs)
	assert(cs[0])
	hold.store(ress, cs[1])
	_pr(hold.holdContent)
	
	cs = hold.can_unload(ress)
	_pr(cs)
	assert(cs[0])
	hold.unload(ress, cs[1])
	_pr(hold.holdContent)

	# Store 6 items, split in 4 and 2
	ress = hold.HoldItem.new("Test_B", hhit.COMMODITY, 25000, 6)
	cs = hold.can_store(ress)
	_pr(cs)
	assert(cs[0])
	hold.store(ress, cs[1])
	_pr(hold.holdContent)

	# Take away 3 from 4
	ress.amount = 3
	cs = hold.can_unload(ress)
	_pr(cs)
	assert(cs[0])
	hold.unload(ress, cs[1])
	_pr(hold.holdContent)
	# Take away just 2, we're left with one cell with 1
	ress.amount = 2
	cs = hold.can_unload(ress)
	hold.unload(ress, cs[1])
	_pr(hold.holdContent)
	# So we can't unload 2
	cs = hold.can_unload(ress)
	assert(!cs[0])
	# Add 1 to another cell
	ress.amount = 1
	hold.store(ress, [Vector3(2, 0, 0)])
	# Now we unload 2
	ress.amount = 2
	cs = hold.can_unload(ress)
	assert(cs[0])


	ress = hold.HoldItem.new("Engine",hhit.ENGINE, 100000, 1)
	cs = hold.can_store(ress)
	_pr(cs)
	assert(cs[0])
	hold.store(ress, cs[1])
	_pr(hold.holdContent)

