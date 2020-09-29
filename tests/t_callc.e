include std/unittest.e
with define SAFE 
include std/dll.e
include std/machine.e
include std/math.e
include std/sequence.e
include std/error.e
include std/convert.e

ifdef not EU4_0 then
	constant pointer_size = sizeof(C_POINTER)
elsedef
	constant C_LONGLONG = -1
	constant C_ULONGLONG = -1
	constant pointer_size = 4
end ifdef

-- one nibble less in magnitude than the smallest number too big to fit into a pointer. 
constant BASE_PTR           = #10 * power(#100,(pointer_size-1))
constant BASE_4             = #10 * power(#100, 3)
constant BASE_8             = #10 * power(#100, 7)
constant SEQ_MASK           = #8 * BASE_PTR
constant NOVALUE            = #C * BASE_PTR - 1
constant MAXUPTR            = #10 * BASE_PTR - 1
constant MAXUINT32          = #10 * BASE_4 - 1 
constant MAXUINT64          = power(2,64) - 1
constant MAXUSHORT          = power(2,16)-1
constant MAXUBYTE           = #FF
constant MININT_EUPHORIA    = -0b0100 * BASE_PTR -- on 32-bit: -1_073_741_824
constant MAXINT_EUPHORIA    =  0b0100 * BASE_PTR - 1
integer gb = 5
constant sum_mul8df_args = { 2, 5, 9, 3.125, 0.0625, 3, 8, 0.5  }
constant sum_mul8df2lli_args = { 0.125-1, 0.750-2, 0.25-3, 0.375-4, -10-5, 3-6, 0.875-7, 1-8, 3-9, -9 }
-- use floor to avoid double / long double conversion issues
-- we must ensure that the number can actually work out the exact number using 64-bit double floats.
constant pow_sum_arg = floor({#BEEF1042/power(2,32)+#B32100,1,#044,3,#BEEF1042/power(2,32)+#B32100,1,#044,3,2,50})

function minus_1_fn() 
	return -1 
end function 

function unsigned_to_signed(atom v, integer t)
	ifdef not EU4_0 then
		integer sign_bit  = shift_bits(1,-sizeof(t) * 8+1)
		if and_bits(sign_bit,v) then
			return v-shift_bits(sign_bit,-1)
		else
			return v
		end if
	elsedef
		if t = C_CHAR then
			if and_bits(128,v) then
				return v-256
			else
				return v
			end if
		else
			crash("not supported")
		end if
	end ifdef
end function

constant ubyte_values = { ' ', 192, 172, ')'}

constant unsigned_types      = {  C_UCHAR,   C_UBYTE,   C_USHORT,   C_UINT,    C_POINTER,   C_ULONGLONG  }
constant unsigned_type_names = { "C_UCHAR", "C_UBYTE", "C_USHORT", "C_UINT",  "C_POINTER", "C_ULONGLONG" }
constant minus_1_values      = { #FF,       #FF,       #FF_FF,      MAXUINT32, MAXUPTR,     MAXUINT64 }
constant unsigned_values     = {ubyte_values, ubyte_values,
														50_000 & 8_000 & 20_000,
																	4_000_000_000 & 420_000_000 & 42,
																				#BEEFDEAD & #C001D00D,
																							(3 & 7) * power(2,58) & 0xD000_0000_0000_0000 }
											
constant floating_point_types = { C_FLOAT, C_DOUBLE },
         floating_point_type_names = { "C_FLOAT", "C_DOUBLE" },
         floating_point_values = { {42.013_183_593_75 /* 17 bits of matissa */},  {float64_to_atom({0, 0, 121, 212, 123, 200, 210, 123})} } 
         
enum false=0, true=1

atom r_max_uint_fn
for i = 1 to length(minus_1_values) do
	r_max_uint_fn = define_c_func( "", call_back( routine_id("minus_1_fn") ), {}, unsigned_types[i] )
    if pointer_size < 8 and unsigned_types[i] = C_ULONGLONG then
        test_true( sprintf("return type %s makes unsigned value", {unsigned_type_names[i]}), c_func(r_max_uint_fn, {}) > 0 )
    else
		test_equal( sprintf("return type %s makes unsigned value", {unsigned_type_names[i]}), minus_1_values[i], c_func(r_max_uint_fn, {}) )
    end if
end for

constant byte_values = ' ' & -32 & -100 & ')'
ifdef EU4_0 then
	constant signed_types      = { C_CHAR,    C_BYTE,   C_SHORT,   C_INT,   C_BOOL,   C_LONG }
	constant signed_type_names = { "C_CHAR", "C_BYTE", "C_SHORT", "C_INT", "C_BOOL", "C_LONG"}
	constant signed_values     = { byte_values, byte_values, 
			-20_000 & 10_000 & 20_000, (2 & -2) * 1e9, true & false, (2 & -2) * power(2,20)}
																			
elsedef
constant signed_types      = { C_CHAR,    C_BYTE,   C_SHORT,   C_INT,   C_BOOL,   C_LONG,   C_LONGLONG }
constant signed_type_names = { "C_CHAR", "C_BYTE", "C_SHORT", "C_INT", "C_BOOL", "C_LONG", "C_LONGLONG"}
constant signed_values     = { byte_values, byte_values, 
			-20_000 & 10_000 & 20_000, (2 & -2) * 1e9, true & false, (2 & -2) * power(2,20), (3 & -2) * power(2,58)} 
end ifdef																		
constant types = signed_types & unsigned_types
constant type_names = signed_type_names & unsigned_type_names
constant values = signed_values & unsigned_values
for i = 1 to length(signed_types) do
    if pointer_size < 8 and find(signed_types[i], C_ULONGLONG & C_LONGLONG) then
        continue
    end if
	-- 32-bit callbacks don't return anything big enough to be a C_LONGLONG, so skip those

	if pointer_size = 8 or signed_types[i] != C_LONGLONG then
		r_max_uint_fn = define_c_func( "", call_back( routine_id("minus_1_fn") ), {}, signed_types[i] )
		test_equal( sprintf("return type %s preserves -1", {signed_type_names[i]}), -1, c_func(r_max_uint_fn, {}) )
	end if
end for

function pow_sum(sequence s)
	atom sum = 0
	for i = 1 to length(s) by 2 do
		atom p = 1
		while s[i+1] > 0 do
			p *= s[i]
			s[i+1] -= 1
		end while
		sum += p
	end for
	return sum
end function

function sum_mul(sequence s)
	atom product = 1
	for i = 1 to length(s) do
		product *= (s[i] + i)
	end for
	return product
end function



function peekf(atom expected_ptr, integer c_type)
	switch c_type do
		case C_CHAR		then return unsigned_to_signed(peek( expected_ptr ), C_CHAR)
		case C_SHORT	then return peek2s( expected_ptr )
		case C_INT      then return peek4s( expected_ptr )
		ifdef not EU4_0 then	
			case C_LONG     then return peek_longs( expected_ptr )
			case C_LONGLONG then return peek8s( expected_ptr )
		elsedef
			case C_LONG then return peek4s( expected_ptr )
		end ifdef
		case C_FLOAT then
			return float32_to_atom(peek( expected_ptr & 4 ))
		case C_DOUBLE then
			return float64_to_atom(peek( expected_ptr & 8 ))
		case else
			return "Unexpected type" 
	end switch
end function

constant lib818 = open_dll("./lib818.dll")

assert( "can open lib818.dll", lib818 )

integer r_near_hashC, r_below_minimum_euphoria_integer, 
	r_above_maximum_euphoria_integer, r_NOVALUE, r_half_MIN, r_half_MAX
object fs
for i = 1 to length(signed_types) do
	-- test that values get encoded well when coming out from C.
	-- test special values and ranges in EUPHORIA
    if pointer_size < 8 and signed_types[i] = C_LONGLONG then
        continue
    end if
	integer test_boundary_values
	ifdef not EU4_0 then
		-- we test bool because bool can be as big as an int. 
		test_boundary_values = sizeof(signed_types[i]) >= sizeof(E_OBJECT) and signed_types[i] != C_BOOL
	elsedef
		-- In 4.0, C_BOOL , C_INT and C_LONG are all the same but we don't have C_BOOL.
		-- We need to compare the strings.
		test_boundary_values = find(signed_type_names[i], {"C_INT", "C_LONG"}) != 0
	end ifdef
	if test_boundary_values then
		-- The underlying library will return values in C values that fit into thier values 
		-- but are out of bounds amoung EUPHORIA integers. 
		r_below_minimum_euphoria_integer = define_c_func( lib818, 
			sprintf("+%s_below_EUPHORIA_MIN_INT", {signed_type_names[i]}), {}, signed_types[i] )
		r_above_maximum_euphoria_integer = define_c_func( lib818, 
			sprintf("+%s_above_EUPHORIA_MAX_INT", {signed_type_names[i]}), {}, signed_types[i] )
		r_NOVALUE = define_c_func(lib818, 
			sprintf("+%s_NOVALUE", {signed_type_names[i]}), {}, signed_types[i])			
		r_half_MIN = define_c_func( lib818, 
			sprintf("+%s_half_MIN", {signed_type_names[i]}), {}, signed_types[i] )
		r_half_MAX = define_c_func( lib818, 
			sprintf("+%s_half_MAX", {signed_type_names[i]}), {}, signed_types[i] )
			
		if r_below_minimum_euphoria_integer != -1 and r_above_maximum_euphoria_integer != -1
		and r_NOVALUE != -1 and r_half_MIN != -1 and r_half_MAX != -1 then
			test_equal(
				sprintf("detect negative values as such for type %s #1",{signed_type_names[i]}),  
				MININT_EUPHORIA-20, c_func(r_below_minimum_euphoria_integer, {}))
			test_equal(
				sprintf("detect negative values as such for type %s #2",{signed_type_names[i]}),  
				floor(MININT_EUPHORIA/2), c_func(r_half_MIN, {}))
			test_equal(
				sprintf("detect NOVALUE as its integer value for type %s",{signed_type_names[i]}),  
				NOVALUE - #10 * BASE_PTR, c_func(r_NOVALUE, {}))
			test_equal(
				sprintf("detect positive values as such for type %s #1",{signed_type_names[i]}),  
				MAXINT_EUPHORIA+20, c_func(r_above_maximum_euphoria_integer, {}))
			test_equal(
				sprintf("detect positive values as such for type %s #2",{signed_type_names[i]}),  
				floor(MAXINT_EUPHORIA/2), c_func(r_half_MAX, {}))
		else
			test_fail(sprintf("opening all functions for type %s", {signed_type_names[i]}))
		end if
	end if
	-- test that values that are sometimes large negative values in C are recognized
	-- These values are #C00...00 - 20.
	r_near_hashC = define_c_func( lib818, sprintf("+%s_BFF_FD", 
		{signed_type_names[i]}), {}, signed_types[i] )
	if r_near_hashC != -1 then
		atom expected_ptr = define_c_var( lib818, "+" & signed_type_names[i] & "_BFFD_value" )
		if expected_ptr > 0 then
			atom expected_val = peekf(expected_ptr, signed_types[i])
			test_equal(sprintf("detect #C00...00-20 correctly for type %s",{signed_type_names[i]}),
				expected_val,
				c_func(r_near_hashC, {}))
		end if
	end if
	integer r_get_m20 = define_c_func( lib818, sprintf("+%s_M20", 
		{signed_type_names[i]}), {}, signed_types[i] )
	if r_get_m20 != -1 then
		test_equal(sprintf("Can get -20 from a function returning that number as a %s", {signed_type_names[i]}), -20, c_func(r_get_m20, {}))
	end if
	integer r_get_m100 = define_c_func( lib818, sprintf("+%s_M100", 
		{signed_type_names[i]}), {}, signed_types[i] )
	if r_get_m100 != -1 then
		atom expected_ptr = define_c_var( lib818, signed_type_names[i] & "_M100_value" )
		test_not_equal( signed_type_names[i] & "_M100_value", -1, expected_ptr )
		if expected_ptr != -1 then
			test_equal(sprintf("Can get -100 like numbers from a function returning that number as a %s", 
				{signed_type_names[i]}), peekf(expected_ptr, signed_types[i]), c_func(r_get_m100, {}))
		end if
	end if
end for
for i = 1 to length(types) do
	integer value_test_counter = 0
	integer id_r = define_c_func(lib818, "+" & type_names[i] & "_id", {types[i]}, types[i])
	test_true(sprintf("%s id function is in our library", {type_names[i]}), id_r != -1)
	for j = 1 to length(values[i]) do
		value_test_counter += 1
		if pointer_size < 8 and find(types[i], {C_LONGLONG, C_ULONGLONG}) then
            -- When working with 64-bit integers on 32-bit, these integers have more matissa precision than
            -- any EUPHORIA type. This means in this case, we should consider two values in EUPHORIA equal if
            -- they are not "integer" types by subtracting them. If the difference is zero, they are equal 
            -- but if the difference is not zero.  Then use the following methodology:			

            -- Take the experimental and control values
			atom experimental = c_func(id_r, {values[i][j]})
			atom control      = values[i][j]
			atom diff = abs(experimental - control)
			-- If either of these values are zero but not both, we should consider them non-equal.
			-- If log2(experimental) - log2(abs(experimental - control)) > 52, then the bits the 
			-- double can store match and we should consider them equal.
			if diff = 0 then
				test_pass(sprintf("Value test for %s #%d\n", {type_names[i], value_test_counter}))
			elsif experimental = 0 then
				test_fail(sprintf("Value test for %s #%d is 0 should be %g", {type_names[i], value_test_counter, control}))
			else
				atom log2_experimental = log(experimental)/log(2)
				atom log2_diff = log(diff)/log(2)
				if log2_experimental - log2_diff <= 52 then
					test_fail(sprintf("Value as good as a double in agreement for %s #%d  [log2(exp=%g)(=%g)] - {[log2(exp(=%g) - control(=%g))](=%g)} < 53?(",
					{type_names[i], value_test_counter, experimental, log2_experimental, experimental, control, log2_diff}))
				else
					test_pass(sprintf("Value as good as a double in agreement for %s #%d  log2(exp)(=%g) - log2(diff)(=%g) < 53?(", {type_names[i], value_test_counter, log2_experimental, log2_diff}))
				end if
			end if
		else		
			test_equal(sprintf("Value test for %s #%d", {type_names[i], value_test_counter}),
				values[i][j], c_func(id_r, {values[i][j]}))
		end if
	end for
end for

ifdef not EU4_0 then
	-- We must use fewer bits than 53 because we EUPHORIA doesn't keep more than 53 bits for numbers.
	-- So even if we return a number that is 63 bits long, and it works we wont be able to verify it as
	-- it would be comparing rounded off values to rounded off values.
	integer bit_repeat_r = define_c_func(lib818, "+bit_repeat", { C_BOOL, C_UBYTE }, C_LONGLONG)
	assert( "Can load bit_repeat_r from lib818", bit_repeat_r != -1)
	test_equal( "5  repeat bits: ", power(2,5)-1, c_func(bit_repeat_r, {1, 5}))
	test_equal( "40 repeating bits: ", power(2,40)-1, c_func(bit_repeat_r, { 1, 40 }))
	test_equal( "2**50: ", power(2,50), c_func(bit_repeat_r, {1, 50})+1)
	test_equal( "-(2**50): ", -power(2,50), -c_func(bit_repeat_r, {1, 50})-1)
end ifdef

integer pow_sum_c = define_c_func(lib818, "+powsum", repeat_pattern( { C_DOUBLE, C_USHORT }, 5 ), C_DOUBLE )
test_equal( "Can call and things are passed correctly for ten argument functions", pow_sum( pow_sum_arg ), 
	c_func( pow_sum_c, pow_sum_arg) )
-- number calculated using arbitrary precision calculator ( a human being, Maple, Python )
test_equal("We are working within the bits of the double", 1125899930950272, pow_sum( pow_sum_arg ))


constant
	OBJECT_FUNC   = define_c_func( lib818, "+object_func", { E_OBJECT }, E_OBJECT ),
	SEQUENCE_FUNC = define_c_func( lib818, "+object_func", { E_SEQUENCE }, E_SEQUENCE ),
	ATOM_FUNC     = define_c_func( lib818, "+object_func", { E_ATOM }, E_ATOM )

test_equal( "object func integer", 5, c_func( OBJECT_FUNC, {5} ) )
test_equal( "object func double", 3.5, c_func( OBJECT_FUNC, {3.5} ) )
test_equal( "object func sequence", "abc", c_func( OBJECT_FUNC, {"abc"}) )

test_equal( "sequence func sequence", "abc", c_func( SEQUENCE_FUNC, {"abc"}) )

test_equal( "atom func integer", 5, c_func( ATOM_FUNC, {5} ) )
test_equal( "atom func double", 3.5, c_func( ATOM_FUNC, {3.5} ) )

ifdef not EU4_0 then
	constant c_sum_mul8df = define_c_func(lib818, "+sum_mul8df", repeat(C_DOUBLE, 8), C_DOUBLE)
	constant c_sum_mul8df2lli = define_c_func(lib818, "+sum_mul8df2lli", repeat(C_DOUBLE, 8) & repeat(C_LONGLONG, 2), C_DOUBLE)
	assert( "sum_mul present in dll", c_sum_mul8df != -1 and c_sum_mul8df2lli != -1 )
	test_equal( "Testing passing eight doubles only", c_func( c_sum_mul8df, sum_mul8df_args ), sum_mul( sum_mul8df_args ) )
	
	-- -0.692138671875
	assert( "Testing expression can be calculated in EUPHORIA", -0.692138671875 = sum_mul( sum_mul8df2lli_args ) )
	test_equal( "Testing passing eight doubles only and two long long ints", -0.692138671875, c_func( c_sum_mul8df2lli, sum_mul8df2lli_args ) )
end ifdef
-- Should put some tests for argument passing as well : passing floating point, double, long long, etc..

constant
	c_sum_8l6d = define_c_func( lib818, "+sum_8l6d", repeat( C_LONG, 8 ) & repeat( C_DOUBLE, 6 ), C_DOUBLE ),
	SUM_8L6D_ARGS = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}
test_equal( "8 longs, 6 doubles", sum( SUM_8L6D_ARGS ), c_func( c_sum_8l6d, SUM_8L6D_ARGS ) )


-- First, numbers used in order to avoid round off have been terminating
-- binary decimals.  That is to say, that numbers like, 0.25 is one bit
-- matissa without repeating decimals, and a hexadecimal number will also
-- be a terminating binary decimal.  But a number like 0.04 is not a
-- terminating binary decimal. 
-- 
-- Second, there are several rules for converting 4-byte to 8-byte doubles.
-- Now, we could get some failures if we have different rounding schemes on
-- different systems.   
-- 
-- The number 0x23_312_123_123 is too big for a 4-byte float but it rounds
-- off to 0x23_312_140_000 rather than what truncation gives us
-- 0x23_312_120_000.  It seems the processor of my computer follows the
-- 'round up' mode. 
-- 
-- To avoid testing for what kind of round off method is used, in making
-- tests values for floats should be six digits of hex and then at least
-- one zero hex digit after that you can add as many digits as you like. 
-- Fractions are possible, hex_text supports decimal point in the numbers.  
-- So you can express fifteen sixteenths as '0.F'
-- for example.  To compute by hand, you need to truncate the four-byte
-- floats to the first six hex digits before adding.

constant c_sum_C_FLOAT_C_DOUBLE = define_c_func( lib818, "+sum_C_FLOAT_C_DOUBLE", { C_FLOAT, C_DOUBLE }, C_DOUBLE )

--     A3_312.123_123 becomes A3_312.1 because floats truncate.
--
--     A3_312.1        (six digits is 24-bits) floats should get truncated.
--    +55_123.421_522
       --------------
--     F8_435.521_522
test_equal("4-byte, 8-byte float sum #1", 
	hex_text("F8_435.521_522"),
	c_func( c_sum_C_FLOAT_C_DOUBLE, { hex_text("A3_312.123_123"), hex_text("55_123.421_522") } )
	 )

--     23_312_10
--   + 55_123_421_522
--    ---------------
--     78 435 521 522
--    
test_equal("4-byte, 8-byte float sum #2", 
	#78_435_521_522,
	c_func( c_sum_C_FLOAT_C_DOUBLE, { hex_text("23_312_103_123"), hex_text("55_123_421_522") } )
	 )
	 

test_equal("4-byte, 8-byte float sum #3", 
	0x23_312_000_000,
	c_func( c_sum_C_FLOAT_C_DOUBLE, { 0x23_312_000_123, 0 } )
	 )

atom signed_buffer = allocate( sizeof( C_POINTER ) )

function f( atom i ) 
	poke_pointer( signed_buffer, i )
	ifdef BITS64 then
		i = peek8s( signed_buffer )
	elsedef
		i = peek4s( signed_buffer )
	end ifdef
    return i
end function 
 
constant r_f  = routine_id( "f") 
constant cb_f = call_back( r_f ) 
constant c_f = define_c_func( {}, cb_f, {C_POINTER}, E_INTEGER ) 
test_equal( "callback properly handles -1", -1, c_func( c_f, {-1} ) )
atom d = -0.5
test_equal( "callback properly handles -1 (double)", -1 , c_func( c_f, {d + d} ) )

test_report()

