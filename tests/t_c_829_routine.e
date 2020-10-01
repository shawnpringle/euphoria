include std/unittest.e

procedure foo( integer x )
    if x then
        goto "x"
    end if
    integer y = 1
    label "x"
    if y then
        ? y
    end if
end procedure

foo(1)
test_pass("Should never reach here.")
test_report()
