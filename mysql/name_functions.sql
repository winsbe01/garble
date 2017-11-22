delimiter |

# get a name based on the input string and the gender
create function garble.gb_name_by_gender (in_name varchar(50), in_gender char(1))
returns varchar(50)
begin
	declare up_name varchar(50);
	declare up_gender char(1);
  declare out_name varchar(50);
	declare mod_num int;

  # standardize on upper case
	set up_name = upper(in_name);
	set up_gender = upper(in_gender);

	# get the row count for the given gender
	select count(*) into mod_num
	from garble.first_names
	where gender = up_gender;

	# get the name based on the input
  select name into out_name
  from garble.first_names
  where id = garble.rz_get_index(up_name, mod_num)
  and gender = up_gender;

  return out_name;
end|

# get a name based on an input string, without regard to gender
create function garble.gb_name(in_name varchar(50))
returns varchar(50)
begin
	declare gender char(1);

	if mod(length(in_name), 2) = 0 then set gender = 'M';
	else set gender = 'F';
	end if;

	return garble.gb_name_by_gender(in_name, gender);
end|

# get a last name based on the input string
create function garble.gb_surname (in_name varchar(100))
returns varchar(100)
begin
	declare up_name varchar(100);
	declare out_name varchar(100);
	declare mod_num int;

  # standardize on upper case
	set up_name = upper(in_name);

	# get the row count
	select count(*) into mod_num
	from garble.last_names;

	# get the name based on the input
	select name into out_name
	from garble.last_names
	where id = garble.rz_get_index(up_name, mod_num);

	return out_name;
end|
