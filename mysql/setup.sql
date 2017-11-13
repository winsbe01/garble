delimiter |

# create the schema, if necessary
create schema if not exists garble|

# based on an MD5 plus stupid math (the MD5 is too big to do math on)
# algorithm:
#    1. take the first 8 digits of the MD5, converted to a decimal
#    2. find #1 mod 4 to give us an offset
#    3. take the #2th 6 digits from the remainder of the MD5
#    4. concatenate #1 and #3 as a bigint
# NOTE: this is likely more trouble than it''s worth
create function garble.rz_hacky_hash(in_str varchar(255))
returns bigint
begin

	declare in_str_hash varchar(40);
	declare head_dec int unsigned;
	declare tail_dec int unsigned;

	declare tail_offset int;

	# get the MD5
	set in_str_hash = md5(in_str);

	# get the first 8 digits as a decimal
	set head_dec = conv(substr(in_str_hash,1,8),16,10);

	# calc the offset to see which other digits to get
	set tail_offset = 9 + (6 * mod(head_dec, 4));

	# get the remaining digits
	set tail_dec = conv(substr(in_str_hash, tail_offset, 6), 16, 10);

	return concat(head_dec, tail_dec);

end|

# gets an "index" based on the hacky_hash of the input,
# modded with a second variable (to keep the result within
# the scope of the requesting function)
CREATE FUNCTION garble.rz_get_index (in_str varchar(255), in_mod int)
RETURNS int
begin
	declare reg bigint;

	# get the numerals from the hash
	set reg = rz_hacky_hash(in_str);

	# get the index from the mod
	return mod(reg, in_mod);

end|
