extends Node

static func try_deal_damage(dealer, receiver):
	_deal_damage(dealer, receiver);

static func _deal_damage(dealer, receiver):
	if 'shields_damage' in dealer.data && 'shields' in receiver:
		var shieldsAbove0 = receiver.shields > 0
		receiver.shields -= dealer.data['shields_damage']
		if shieldsAbove0 && receiver.shields == 0:
			# don't deal armour damage on top
			return
	if 'armour_damage' in dealer.data && 'armour' in receiver:
		receiver.armour -= dealer.data['armour_damage']
