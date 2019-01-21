include std/unittest.e
with define SAFE 
include std/dll.e
include std/machine.e
include std/math.e
include std/sequence.e
include std/error.e
include std/convert.e

atom signed_buffer = allocate( sizeof( C_POINTER ) )
poke(signed_buffer, repeat(0, sizeof( C_POINTER) ) )

override procedure poke_pointer( atom ptr, object val )
    printf(2, "Calling poke_pointer(%016x, %d)\n", {ptr,val})
    eu:poke_pointer( ptr, val )
end procedure

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
-- in this call to poke_pointer, -nan is actually passed instead of -1.  Why?
constant handle_int_m1_ret = c_func( c_f, {-1})
test_equal( "callback to routine causes side effect", 256+repeat(-1,sizeof( C_POINTER )), peek(signed_buffer & sizeof( C_POINTER )))
test_equal( "callback properly handles -1", -1, handle_int_m1_ret )
-- in this call to poke_pointer, -1 is passed
poke_pointer( signed_buffer, -1 )
test_equal( "direct call to poke_pointer -1 sets all bits on", 256+repeat(-1,sizeof( C_POINTER )), peek(signed_buffer & sizeof( C_POINTER )))
constant direct_peek = peek8s( signed_buffer )
test_equal( "direct peek shows -1", -1, direct_peek)
atom d = -0.5
-- in this call to poke_pointer, 0 is passed.  Why?
test_equal( "callback properly handles -1 (double)", -1 , c_func( c_f, {d + d} ) )

test_report()

