delimiter |

# get a "garbled" year, based on the input date as well as
# a "tolerance", or how much above/below it can be
create function garble.rz_get_year_by_tol(in_date date, in_tol int)
returns int
begin
	declare low_year int;
	declare high_year int;
	declare calc_range int;

	# calculate year range
	set low_year = year(in_date) - in_tol;
	set high_year = year(in_date) + in_tol;

	# re-set high year, so we dont go above our current year
	if high_year > year(curdate()) then set high_year = year(curdate());
	end if;

	# calculate the range -- should be 2 * in_tol,
	# unless in_date is less than in_tol years ago
	set calc_range = high_year - low_year;

	# calculate the year
	return low_year + garble.rz_get_index(date_format(in_date, "%Y-%m-%d"), calc_range);

end|

# get the number of days in an inputted year
create function garble.rz_days_in_year(in_year int)
returns int
begin
	return dayofyear(concat(in_year, "-12-31"));
end|

# get a "garbled" day of year (i.e. February 2 is the 33rd day of a year)
# based on the input date and the year to calc a day for
create function garble.rz_get_day_of_year(in_date date, in_year int)
returns int
begin

	declare days_mod int;

	# our max days is the number of days in the year,
	# unless it's the current year, in which case it's the current year-day
	if in_year = year(curdate()) then set days_mod = dayofyear(curdate());
	else set days_mod = garble.rz_days_in_year(in_year);
	end if;

	return garble.rz_get_index(date_format(in_date, "%Y-%m-%d"), days_mod);

end|

# get a "garbled" date based on an input date and
# a "tolerance", or how many years +/- the original it should fall within
create function garble.gb_date_by_tol(in_date date, in_tol int)
returns date
begin

	declare out_year int;
	declare out_doy int;

	set out_year = garble.rz_get_year_by_tol(in_date, in_tol);
	set out_doy = garble.rz_get_day_of_year(in_date, out_year);

	return makedate(out_year, out_doy);

end|
