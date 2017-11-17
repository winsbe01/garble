delimiter |

# AAA-GG-SSSS
# Traditionally, the first 3 are an "area code",
# the second 2 are a "group code",
# and the last 4 are random.
#
# This changed in 2011 -- now it's all random,
# but there are a few "reserved" area codes,
# including 900-999, which we're mimicking here.
#
# These won't truly be valid SSNs, but should pass
# high-level validation (along with looking like an SSN).
create function garble.gb_ssn(in_ssn varchar(150))
returns varchar(9)
begin

	declare ssn_index bigint;
	
	# get the hash integer
	set ssn_index = garble.rz_hacky_hash(in_ssn);
	
	# return a "9" followed by the first 8 digits
	return concat("9",substring(ssn_index,1,8));

end|

# calculates the check digit based on the Luhn algorithm
# takes in the first 15 digits of the final card number
create function garble.rz_calc_luhn_check_digit(in_num bigint)
returns int
begin
	
	declare ix int default 0;
	declare running_sum int default 0;
	declare cur_dig int;

	if length(in_num) <> 15 then return -1;
	end if;
	
	l_head : loop
		set ix = ix + 1;
		if ix <= 15 then 
		
			set cur_dig = substring(in_num,ix,1);
			
			if mod(ix,2) = 0 then set running_sum = running_sum + cur_dig;
			elseif cur_dig < 5 then set running_sum = running_sum + cur_dig + cur_dig;
			else set running_sum = running_sum + (cur_dig - (9 - cur_dig));
			end if;
			
			iterate l_head;

		end if;
		leave l_head;
	end loop l_head;
	
	return 10 - mod(running_sum,10);

end|

# most credit cards are 16 digits long
# the first (up to) 6 digits are reserved by provider (Visa, MasterCard, etc)
# the final digit is calculated using the Luhn algorithm
# (https://en.wikipedia.org/wiki/Luhn_algorithm)
# This function will generate a valid card number, based on type
create function garble.gb_ccard_by_type(in_cc varchar(16), in_gen_type char(2))
returns varchar(16)
begin

	declare in_cc_hash bigint;
	declare iin int;
	declare base_num bigint;
	
	# find the correct IIN based on the card type
	if in_gen_type = 'AX' then set iin = 34;
	elseif in_gen_type = 'DV' then set iin = 6011;
	elseif in_gen_type = 'MC' then set iin = 51;
	elseif in_gen_type = 'VS' then set iin = 4;
	else set iin = 5610; # this IIN is no longer in use
	end if;
	
	# generate the base number -- 15 digits, beginning with the IIN
	set base_num = concat(iin, substring(garble.rz_hacky_hash(in_cc), 1, (15 - length(iin))));
	
	# find the check digit, append it to the base number
	return concat(base_num, garble.rz_calc_luhn_check_digit(base_num));

end|

# generates a valid credit card number with a discontinued IIN
# RECOMMENDED, unless you need to test (or are limited by) the card type
create function garble.gb_ccard(in_cc varchar(16))
returns varchar(16)
begin
	# return the default card type
	return garble.gb_ccard_by_type(in_cc, '');
end|
