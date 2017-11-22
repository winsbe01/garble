delimiter |

# generates an email address based on the hash
# the domain is example.org, example.net or example.com
create function garble.gb_email(in_email varchar(255))
returns varchar(255)
begin

	declare def_domain varchar(9);
	declare email_mask int;
	declare ext_flag int;
	
	declare out_email varchar(255);
	
	set def_domain = "@example.";
	set email_mask = garble.rz_get_index(in_email, 10000000);
	set ext_flag = mod(email_mask, 3);
	
	if ext_flag = 0 then set out_email = concat(email_mask, def_domain, "com");
	elseif ext_flag = 1 then set out_email = concat(email_mask, def_domain, "org");
	else set out_email = concat(email_mask, def_domain, "net");
	end if;
	
	return out_email;

end|

# creates a masked email address based on the firstname and lastname
# will garble each individually, then return an email address of format:
#    <first initial><lastname>@example.<com|org|net>
create function garble.gb_email_by_name(in_firstname varchar(50), in_lastname varchar(100))
returns varchar(255)
begin

	declare def_domain varchar(9);
	declare mask_firstname varchar(50);
	declare mask_lastname varchar(100);
	declare ext_flag int;
	declare user_name varchar(50);
	declare out_email varchar(255);
	
	set def_domain = "@example.";
	
	set mask_firstname = garble.gb_name(in_firstname);
	set mask_lastname = garble.gb_surname(in_lastname);
	
	set ext_flag = mod(length(in_firstname) + length(in_lastname), 3);
	
	set user_name = lower(concat(substring(mask_firstname, 1, 1), mask_lastname));
	
	if ext_flag = 0 then set out_email = concat(user_name, def_domain, "com");
	elseif ext_flag = 1 then set out_email = concat(user_name, def_domain, "org");
	else set out_email = concat(user_name, def_domain, "net");
	end if;
	
	return out_email;
	
end|

# generates a phone number from the input string
# the first digit in the area code is a 1 -- this means
# the number is technically invalid, according to the
# North American Numbering Plan. This is so no real phone
# number is generated
create function garble.gb_phone(in_phone varchar(255))
returns varchar(10)
begin

	declare mask_phone varchar(9);
	
	set mask_phone = substring(garble.rz_hacky_hash(in_phone), 1, 9);
	
	return concat("1", mask_phone);

end|

# generates a phone number according to the input format:
#   %A => area code (first 3 numbers)
#   %E => exchange code (middle 3 numbers)
#   %L => line number (last 4 digits)
# uses garble.gb_phone, so they can be used interchangebly
# with the same number as a result
create function garble.gb_phone_with_format(in_phone varchar(255), in_format varchar(25))
returns varchar(25)
begin

	declare mask_phone varchar(10);
	
	declare rep_area varchar(25);
	declare rep_exchange varchar(25);
	declare rep_line varchar(25);
	
	# make sure we have a proper format string
	if instr(in_format, "%A") = 0 
		or instr(in_format, "%E") = 0
		or instr(in_format, "%L") = 0
		then return "0";
	end if;
	
	# get the masked phone number
	set mask_phone = garble.gb_phone(in_phone);
	
	# fit the masked number into the format
	set rep_area = replace(in_format, "%A", substring(mask_phone, 1, 3));
	set rep_exchange = replace(rep_area, "%E", substring(mask_phone, 4, 3));
	set rep_line = replace(rep_exchange, "%L", substring(mask_phone, 7, 4));

	return rep_line;

end|

