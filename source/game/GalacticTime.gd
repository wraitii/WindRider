extends Node

### GalacticTime
## Godot has no date-time class so hand-roll one
## Thankfully I don't deal with timezones so thous should be reasonably easy.
## No handling of bisextiles years for now.
## Month/Day are 0-indexed internally, and 1-indexed externally.

var year : int;
var day : int;
var ms : float;

const DAYS_IN_YEAR = 365;

const MIN_LENGTH  = 60 * 1000;
const HOUR_LENGTH = 60 * MIN_LENGTH;
const DAY_LENGTH  = 24 * HOUR_LENGTH;
const YEAR_LENGTH = DAYS_IN_YEAR * DAY_LENGTH;
const MONTH_LENGTH = [31,28,31,30,31,30,31,31,30,31,30,31]

const PADDED_0_IDX = {
	0  : '01', 1 : '02', 2 : '03', 3 : '04', 4 : '05', 5 : '06', 6 : '07', 7 : '08', 8 : '09',9 : '10', 10 : '11', 11 : '12', 12 : '13', 13 : '14', 14 : '15', 15 : '16', 16 : '17', 17 : '18', 18 : '19',19 : '20', 20 : '21', 21 : '22', 22 : '23', 23 : '24', 24 : '25', 25 : '26', 26 : '27', 27 : '28', 28 : '29',29 : '30', 30 : '31'
}

const PADDED = {
	0 : '00', 1 : '01', 2 : '02', 3 : '03', 4 : '04', 5 : '05', 6 : '06', 7 : '07', 8 : '08', 9 : '09', 10 : '10',  11 : '11', 12 : '12', 13 : '13', 14 : '14', 15 : '15', 16 : '16', 17 : '17', 18 : '18', 19 : '19', 20 : '20', 21 : '21', 22 : '22', 23 : '23', 24 : '24', 25 : '25', 26 : '26', 27 : '27', 28 : '28', 29 : '29', 30 : '30', 31 : '31', 32 : '32', 33 : '33', 34 : '34', 35 : '35', 36 : '36', 37 : '37', 38 : '38', 39 : '39', 40 : '40', 41 : '41', 42 : '42', 43 : '43', 44 : '44', 45 : '45', 46 : '46', 47 : '47', 48 : '48', 49 : '49', 50 : '50', 51 : '51', 52 : '52', 53 : '53', 54 : '54', 55 : '55', 56 : '56', 57 : '57', 58 : '58', 59 : '59'
}

func _init(y,m,d,h,mm):
	year = y;
	day = _month_day_to_day(m-1, d-1);
	ms = _hour_min_to_ms(h, mm);

func serialize():
	var ret = {}
	ret.year = year;
	ret.day = day;
	ret.ms = ms;
	return ret

func deserialize(t):
	year = t.year;
	day = t.day;
	ms = t.ms;

func add_time(milliseconds):
	var remaining = _add_years(milliseconds);
	remaining = _add_days(remaining);
	_add_ms(remaining);

func add_years(y):
	add_time(y*DAYS_IN_YEAR*DAY_LENGTH);

func add_days(d):
	add_time(d*DAY_LENGTH);

func add_hours(h):
	add_time(h*HOUR_LENGTH);

func add_minutes(m):
	add_time(m*MIN_LENGTH);

func get_iso():
	var st = str(year)
	st += '-'
	st += PADDED_0_IDX[_days_to_month(day)]
	st += '-'
	st += PADDED_0_IDX[_days_in_month(day)]
	st += ' '
	st += PADDED[_ms_to_hours(ms)]
	st += ':'
	st += PADDED[_ms_to_minute(ms)]
	return st

########################
########################
#### Private interface

func _days_in_month(d):
	var daysLeft = d;
	for i in range(0,12):
		if daysLeft < MONTH_LENGTH[i]:
			return daysLeft;
		daysLeft -= MONTH_LENGTH[i];

func _days_to_month(d):
	var daysLeft = d;
	for i in range(0,12):
		if daysLeft < MONTH_LENGTH[i]:
			return i;
		daysLeft -= MONTH_LENGTH[i];

func _month_to_days(m):
	var ret = 0;
	for i in range(0, m):
		ret += MONTH_LENGTH[i];
	return ret;

func _month_day_to_day(m, day_0_indexed):
	return _month_to_days(m) + day_0_indexed;

func _ms_to_hours(ms):
	return int(floor(ms / HOUR_LENGTH));

func _ms_to_minute(ms):
	return int(floor(int(floor(ms)) % HOUR_LENGTH) / MIN_LENGTH);

func _hour_min_to_ms(h, m):
	return (h * 60 + m) * MIN_LENGTH;

######

func _add_years(milliseconds):
	var to_add = int(floor(milliseconds / (DAY_LENGTH * DAYS_IN_YEAR)));
	year += to_add;
	return milliseconds - to_add * YEAR_LENGTH;

func _add_days(milliseconds):
	var to_add = int(floor(milliseconds / DAY_LENGTH));
	day += to_add;
	if day >= DAYS_IN_YEAR:
		_add_years(YEAR_LENGTH);
		day -= DAYS_IN_YEAR;
	return milliseconds - to_add * DAY_LENGTH;

func _add_ms(milliseconds):
	ms += milliseconds;
	if ms >= DAY_LENGTH:
		_add_days(DAY_LENGTH)
		ms -= DAY_LENGTH;
	return 0;

