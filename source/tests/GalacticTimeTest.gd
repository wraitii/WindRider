extends Node

const GT = preload('../game/GalacticTime.gd');

func _init():
	var gt = GT.new(2018, 1, 1, 0,0);
	assert(gt.get_iso() == "2018-01-01 00:00")

	gt = GT.new(2018, 1, 1, 12,34);
	assert(gt.get_iso() == "2018-01-01 12:34")
	
	gt = GT.new(2018, 12, 31, 0,0);
	assert(gt.get_iso() == "2018-12-31 00:00")

	gt = GT.new(2018, 12, 31, 23,59);
	assert(gt.get_iso() == "2018-12-31 23:59")

	gt.add_minutes(1);
	assert(gt.get_iso() == "2019-01-01 00:00")

	gt.add_minutes(60*4 + 19);
	assert(gt.get_iso() == "2019-01-01 04:19")

	gt.add_hours(4);
	assert(gt.get_iso() == "2019-01-01 08:19")

	gt.add_hours(23);
	assert(gt.get_iso() == "2019-01-02 07:19")

	gt.add_days(23);
	assert(gt.get_iso() == "2019-01-25 07:19")

	gt.add_days(7);
	assert(gt.get_iso() == "2019-02-01 07:19")

	gt.add_days(28);
	assert(gt.get_iso() == "2019-03-01 07:19")

	gt.add_years(2);
	assert(gt.get_iso() == "2021-03-01 07:19")

	gt.add_time(2 * 3600*24*365*1000 + 189894*1000);
	assert(gt.get_iso() == "2023-03-03 12:03")