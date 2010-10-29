include std/unittest.e
include std/filesys.e

include std/image.e
include std/console.e

sequence palette = { {1,1,1} }
sequence image = {
	{ 1, 0, 1, 0 },
	{ 0, 1, 0, 1 }
	}

procedure test_bmp( integer i, sequence p, sequence img )
	test_equal( sprintf("save bitmap %d", i), BMP_SUCCESS, save_bitmap( { p, img }, "test.bmp" ) )
	test_true( sprintf( "read bitmap sequence %d", i ), sequence( read_bitmap("test.bmp") ) )
	delete_file( "test.bmp" )
end procedure

delete_file( "test.bmp" )
-- test the various palette sizes...
for i = 1 to 7 do
	palette &= palette + 1
	if find( length(palette), { 2, 4, 16, 256} ) then
		test_bmp( i, palette, image )
	end if
end for


test_equal( "no bmp file", BMP_OPEN_FAILED, read_bitmap("not a real file" ) )


test_report()
