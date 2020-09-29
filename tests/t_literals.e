-- t_literals.e

include std/unittest.e
include std/scinot.e

-- Hexadecimal literals
test_equal("Hex Lit 1", -4275878552, -#FEDC_BA98)
test_equal("Hex Lit 2", 1985229328, #7654_3210)
test_equal("Hex Lit 3", 11259375, #aB_cDeF)

test_equal("Integer Lit 1", 11259375, 11_259_375)

test_equal("Float Lit 1", 11259.3756, 11_259.375_6)

test_equal("Binary Lit 1", 15, 0b1111)
test_equal("Octal Lit 1", 585, 0t1111)
test_equal("Dec Lit 1", 1111, 0d1111)
test_equal("Hex Lit 4", 4369, 0x1111)

test_equal("Binary Lit 2", 11, 0B1011)
test_equal("Octal Lit 2", 521, 0T1011)
test_equal("Dec Lit 2", 1011, 0D1011)
test_equal("Hex Lit 5", 4113, 0X1011)

test_equal("Hex Lit 6", -1073741824, -0x4000_0000)
test_not_equal("Hex Lit 6", 0, -0x4000_0000)

/*-------------------------------------------------------
   Extended string literals.
   Make sure each /* allowable */ syntax form is permitted.
-------------------------------------------------------- */
test_equal("Extended string literal 1", "`one` `two`", """`one` `two`""")
test_equal("Extended string literal 2", "\"one\" \"two\"", `"one" "two"`)


/* Test for string which extend over multiple lines. */
integer c1 = 0
integer c2 = 0

/* C1 */ c1 = 1 /* C2 */ c2 = 1 /* eoc */
test_equal("Dual comments", {1,1}, {c1, c2})

sequence _s
_s = `

"three'
'four"

`
test_equal("Extended string literal A", "\n\"three'\n'four\"\n", _s)

_s = `
"three'
'four"
`
test_equal("Extended string literal B", "\"three'\n'four\"", _s)


_s = `"three'
'four"
`
test_equal("Extended string literal C", "\"three'\n'four\"\n", _s)


_s = `
________
        Dear Mr. John Doe, 
        
            I am very happy for your support 
            with respect to the offer of
            help.
        
     Mr. Jeff Doe 
`
sequence t = """
Dear Mr. John Doe, 

    I am very happy for your support 
    with respect to the offer of
    help.

Mr. Jeff Doe 
"""

test_equal("Extended string literal D", t, _s)
     

_s = """
__________________if ( strcmp( "foo", "bar" ) == 1 ) {
                       printf("strcmp works correctly.");
                  }
"""

t = `if ( strcmp( "foo", "bar" ) == 1 ) {
     printf("strcmp works correctly.");
}
`
test_equal("Extended string literal E", t, _s)

test_equal("Escaped strings - newline",         {10}, "\n")
test_equal("Escaped strings - tab",             {09}, "\t")
test_equal("Escaped strings - carriage return", {13}, "\r")
test_equal("Escaped strings - back slash",      {92}, "\\")  
test_equal("Escaped strings - dbl quote",       {34}, "\"")
test_equal("Escaped strings - sgl quote",       {39}, "\'")
test_equal("Escaped strings - null",            {00}, "\0")

test_equal("Escaped strings - hex", {0xAB, 0xDF, 0x01, 0x2E}, "\xab\xDF\x01\x2E")
test_equal("Escaped strings - u16", {0xABDF, 0x012E}, "\uabDF\u012E")
test_equal("Escaped strings - U32", {0xABDF012E}, "\UabDF012E")

test_equal("Escaped characters - newline",         10, '\n')
test_equal("Escaped characters - tab",             09, '\t')
test_equal("Escaped characters - carriage return", 13, '\r')
test_equal("Escaped characters - back slash",      92, '\\')  
test_equal("Escaped characters - dbl quote",       34, '\"')
test_equal("Escaped characters - sgl quote",       39, '\'')
test_equal("Escaped characters - null",            00, '\0')
test_equal("Escaped characters - escape #1",       27, '\e')
test_equal("Escaped characters - escape #2",       27, '\E')

test_equal("Escaped characters - binary", {0xA, 0xDF, 0x01, 0x12E}, {'\b1010','\b11011111','\b0000_0001','\b1_0010_1110'})

test_equal("Escaped characters - hex", {0xAB, 0xDF, 0x01, 0x2E}, {'\xab','\xDF','\x01','\x2E'})
test_equal("Escaped characters - u16", {0xABDF, 0x012E}, {'\uabDF','\u012E'})
test_equal("Escaped characters - U32", {0xABDF012E}, {'\UabDF012E'})

test_equal("Binary strings - no punc", {0x1,0xDF,0x012E}, b"1 11011111 100101110")
test_equal("Binary strings - with punc", {0x1,0xDF,0x012E}, b"1 11_01_11_11 1_0010_1110")
test_equal("Binary strings - multiline", {0x1,0xDF,0x012E}, b"1 
                                                              11_01_11_11 
                                                              1_0010_1110")

test_equal("Hex strings - no punc", {0xAB,0xDF,0x01,0x2E}, x"abDF012E")
test_equal("Hex strings - with punc", {0xAB,0x0D,0xF0,0x12,0xEF,0x03}, x"ab D F0__12Ef3")
test_equal("Hex strings - multiline", {0xAB,0x0D,0xF0,0x12,0xEF,0x03}, x"ab
                                                                         D 
                                                                         F0__12Ef3
                                                                         ")

test_equal("utf16 strings - no punc", {0xABDF,0x012E}, u"abDF012E")
test_equal("utf16 strings - with punc", {0xAB,0x0D,0xF012, 0x0EF3}, u"ab D F0__12Ef3")
test_equal("utf16 strings - no punc 2", {0xABDF, 0x012E, 0x1234, 0x5678, 0xFEDC, 0xBA98}, u"abDF012E12345678FEDCBA98")
test_equal("utf16 strings - multiline", {0xABDF, 0x012E, 0x1234, 0x5678, 0xFEDC, 0xBA98}, 
														u"abDF
														  012E
														  12345678
														  FEDC
														  
														  
														  BA98")
 
test_equal("utf32 strings - no punc", {0xABDF012E, 0x12345678, 0xFEDCBA98}, U"abDF012E 12345678 FEDCBA98 ")
test_equal("utf32 strings - with punc", {0xAB,0x0D,0x0F012EF3}, U"  ab D F0__12Ef3  ")
test_equal("utf32 strings - multiline", {0xAB,0x0D,0x0F012EF3}, U"  
                                                                   ab 
                                                                   D 
                                                                   F0__12Ef3
                                                                     ")
                                                                     

enum type colors by * 2.3 BLUE, BLACK, WHITE=13, RED, GREEN, CYAN=94.3 end type

test_equal("enum values", {1, 2.3, 13, 29.9, 68.77, 94.3}, {BLUE, BLACK, WHITE, RED, GREEN, CYAN})
test_true("enum type func", colors(GREEN))

constant MINVAL_1 = 2.0  
atom     MINVAL_2 = 2.0  
  
function doit()  
  
   atom amt1 = 0  
   atom amt2 = 0  
   atom amt3 = 0  
   atom amt4 = 0  
  
   amt1 += MINVAL_1  
   amt2 -= MINVAL_1  
  
   amt3 += MINVAL_2  
   amt4 -= MINVAL_2  
  
   return 0  
  
end function  
test_equal( "Constant floating point with zero fraction", 0, doit() )
test_equal( "0b1.11111111e354", power(2,300)*(power(2,55)-2), scientific_to_atom("73391955711682284297474315980694609568598702834628673856666055528509030762550615149477994172850609602953216e0") )
-- the following four are equivalent.
ifdef BITS32 then
	test_equal( "0b1.11111111e1022 #1", power(2,968)*(power(2,55)-2), scientific_to_atom("0.89884656743115795e308") )
	test_equal( "0b1.11111111e1022 #2", power(2,968)*(power(2,55)-2), scientific_to_atom("898846567.43115795e299" ) )
	test_equal( "0b1.11111111e1022 #3", power(2,968)*(power(2,55)-2), scientific_to_atom("89884656743115795e291") )
	test_equal( "0b1.11111111e1022 #4", power(2,968)*(power(2,55)-2), scientific_to_atom("8.9884656743115795e307") )
	
	test_equal( "1E308 #1",             power(10,308), scientific_to_atom("1e308") )
	test_equal( "1E308 #2",             power(10,308), scientific_to_atom("0.001e311") )
	test_equal( "1E308 #3",             power(10,308), scientific_to_atom("0.1e309") )
	test_equal( "1E308 #4",             power(10,308), scientific_to_atom("10e307") )
	test_equal( "1E308 #5",             power(10,308), scientific_to_atom("1000e305") )
	
	test_equal( "inf  #1", 1e308*10, scientific_to_atom("1e309") )
	test_equal( "inf  #2", 1e308*10, scientific_to_atom("0.001e312") )
	test_equal( "inf  #3", 1e308*10, scientific_to_atom("0.1e310") )
	test_equal( "inf  #4", 1e308*10, scientific_to_atom("10e308") )
	test_equal( "inf  #5", 1e308*10, scientific_to_atom("1000e306") )
	
end ifdef

test_equal( "42555", 42555, 4.2555e4 )
test_equal( "Plank", 6.62606957 * power(10,-34), 6.62606957e-34 )
--
--
-- The following test fails.  The values look the same, but when you look at the bits produced, you'll find the most insignificant bits 
-- between these two differ.  All of the 63 other bits match. 
--     include std/scinot.e
--     include std/convert.e
--     ? bytes_to_bits(scientific_to_float("6.022141e23"))
--     ? bytes_to_bits(atom_to_float64(6.022141 * power(10,23)))
--     {0,0,1,0,1,1,1,1,0,0,1,1,1,1,0,1,0,0,0,1,0,1,0,1,1,1,1,1,1,0,1,1,1,0,1,0,0,0,0,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,1,1,0,0,1,0,0,0,1,0}
--     {1,0,1,0,1,1,1,1,0,0,1,1,1,1,0,1,0,0,0,1,0,1,0,1,1,1,1,1,1,0,1,1,1,0,1,0,0,0,0,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,1,1,0,0,1,0,0,0,1,0}
-- A number that is a terminating decimal in base-10, is often a repeating decimal in base-2.  After some reading, this doesn't really 
-- appear to really be a bug but just a characteristic a representation of a non-terminating decimal fraction (or binary fraction).
-- For example:  If rounding to thousandths, 0.333 is within 0.0005 of one third. Now when we multiply by 3 we get 0.999, rather than 1.  
-- The expected error should be in this interval [-0.0015,0.0015].  Percentage wise,
-- So, we see that for each number  the machine epsilon is 100*power(2,-54)% of each value.  Multiplying these intervals means
-- we only should demand the outcome of being within 100*(power(2,-53)+power(2,-104))% within the real product.  So the highest acceptable
-- difference should be 3*power(2,-54) proportionally between the two.
test_equal( "Avagadro #1", 6.022141 * power(10,23), scientific_to_atom("6.022141e23") )
test_equal( "Avagadro #2", 6.0221412e23, scientific_to_atom("0.60221412e24") )
test_equal( "Avagadro #3", 6.0221412e23, scientific_to_atom("6022.1412e20") )
test_equal( "Avagadro #4", 6.0221412e23, scientific_to_atom("60221412e16") )
test_equal( "Something looks bigger than it is #1", 8.8e307, scientific_to_atom("0000008.8e307") )
test_equal( "Something looks bigger than it is #2", 0, scientific_to_atom("000002e-324"))

test_equal( "0b1.11111111e53", power(2,53)-1, 9007199254740991 )
test_equal( "0b1.11111111e-55", 1 - power(2,-53), 0.99999999999999988897769753748434595763683319091796875 ) 
-- ridiculously long literals:
test_false("Excessively long 0 doesn't cause an error and is read as 0", 0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)
test_equal("Excessively long 1/9 doesn't cause an error", 1, 9 * 0.1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111)
test_report()
