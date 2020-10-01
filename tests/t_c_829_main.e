include std/unittest.e
integer x = 1
if x then
	goto "x"
end if
integer y = 1
label "x"
if y then
	? y
end if

test_pass("Should never reach here.")
test_report()
