include std/filesys.e
include std/io.e
include std/unittest.e
include std/text.e

sequence fullname, pname, fname, fext, eolsep, driveid
integer sep

ifdef UNIX then
    fullname = "/opt/euphoria/docs/readme.txt"
    pname = "/opt/euphoria/docs"
    sep = '/'
    eolsep = "\n"
    driveid = ""
elsedef
    fullname = "C:\\EUPHORIA\\DOCS\\readme.txt"
    pname = "\\EUPHORIA\\DOCS"
    sep = '\\'
    eolsep = "\r\n"
    driveid = "C"
end ifdef

fname = "readme"
fext = "txt"

test_equal("pathinfo() fully qualified path", {pname, fname & '.' & fext, fname, fext, driveid},
    pathinfo(fullname))
test_equal("pathinfo() no extension", {pname, fname, fname, "", ""},
    pathinfo(pname & SLASH & fname))
test_equal("pathinfo() no dir", {"", fname & '.' & fext, fname, fext, ""}, pathinfo(fname & "." & fext))
test_equal("pathinfo() no dir, no extension", {"", fname, fname, "", ""}, pathinfo("readme"))

test_equal("dirname() full path", pname, dirname(fullname))
test_equal("dirname() filename only", "", dirname(fname & "." & fext))

test_equal("filename() full path", fname & "." & fext, filename(fullname))
test_equal("filename() filename only", fname & "." & fext, filename(fname & "." & fext))
test_equal("filename() filename no extension", fname, filename(fname))

test_equal("fileext() full path", fext, fileext(fullname))
test_equal("fileext() filename only", fext, fileext(fullname))
test_equal("fileext() filename no extension", "", fileext(fname))
test_equal("fileext() with period in the filename", "txt", fileext("hello.world.txt"))

test_equal("defaultext #1", "abc.def", defaultext("abc", "def"))
test_equal("defaultext #2", "abc.xyz", defaultext("abc.xyz", "def"))
test_equal("defaultext #3", "abc.xyz" & SLASH & "abc.xyz", defaultext("abc.xyz" & SLASH & "abc.xyz", "def"))
test_equal("defaultext #4", "abc.xyz" & SLASH & "abc.def", defaultext("abc.xyz" & SLASH & "abc", "def"))


test_equal("SLASH", sep, SLASH)
test_equal("EOLSEP", eolsep, EOLSEP)

test_equal("file_exists #1", 1, file_exists("t_filesys.e"))
test_equal("file_exists #2", 0, file_exists("nononononono.txt"))
test_equal("file_exists #3", 0, file_exists( 1 ))

test_false("absolute_path('')", absolute_path(""))
test_true("absolute_path('/usr/bin/abc')", absolute_path("/usr/bin/abc"))
test_false("absolute_path('../abc')", absolute_path("../abc"))
test_false("absolute_path('local/abc.txt')", absolute_path("local/abc.txt"))
test_false("absolute_path('abc.txt')", absolute_path("abc.txt"))
test_false("absolute_path('c:..\\abc')", absolute_path("c:..\\abc"))
test_false("absolute_path('a')", absolute_path("a"))
test_false("absolute_path('ab')", absolute_path("ab"))
test_false("absolute_path('a:')", absolute_path("a:"))
test_false("absolute_path('a:b')", absolute_path("a:b"))

ifdef WINDOWS then
	test_true("absolute_path('\\temp\\somefile.doc')", absolute_path("\\temp\\somefile.doc"))
	test_true("absolute_path('c:\\windows\\system32\\abc')", absolute_path("c:\\windows\\system32\\abc"))
	test_true("absolute_path('c:/windows/system32/abc')", absolute_path("c:/windows/system32/abc"))
elsedef
	test_false("absolute_path('c:\\windows\\system32\\abc')", absolute_path("c:\\windows\\system32\\abc"))
	test_false("absolute_path('c:/windows/system32/abc')", absolute_path("c:/windows/system32/abc"))
end ifdef

-- move_file()
delete_file("fstesta.txt")
delete_file("fstestb.txt")
write_file("fstesta.txt", "move data", TEXT_MODE)
test_true("move_file #1", move_file("fstesta.txt", "fstestb.txt", 1))
test_true("move_file #2", sequence( dir("fstestb.txt"))) -- 'b' should now exist
test_false("move_file #3", sequence( dir("fstesta.txt"))) -- 'a' should now be gone
write_file("fstesta.txt", "some data", TEXT_MODE)
test_false("move_file #4", move_file("fstesta.txt", "fstestb.txt")) -- should not overwrite existing file
test_false("move_file #5", move_file("fstesta.txt", "fstestb.txt", 0)) -- should not overwrite existing file
test_true("move_file #6", move_file("fstesta.txt", "fstestb.txt", 1)) -- should overwrite existing file
delete_file("fstesta.txt")
delete_file("fstestb.txt")

-- rename_file()
delete_file("fstesta.txt")
delete_file("fstestb.txt")
write_file("fstesta.txt", "rename data", TEXT_MODE)
test_true("rename_file #1", rename_file("fstesta.txt", "fstestb.txt", 1))
test_true("rename_file #2", sequence( dir("fstestb.txt"))) -- 'b' should now exist
test_false("rename_file #3", sequence( dir("fstesta.txt"))) -- 'a' should now be gone
write_file("fstesta.txt", "some data", TEXT_MODE)
test_false("rename_file #4", rename_file("fstesta.txt", "fstestb.txt")) -- should not overwrite existing file
test_false("rename_file #5", rename_file("fstesta.txt", "fstestb.txt", 0)) -- should not overwrite existing file
test_true("rename_file #6", rename_file("fstesta.txt", "fstestb.txt", 1)) -- should overwrite existing file
delete_file("fstesta.txt")
delete_file("fstestb.txt")

-- copy_file()
delete_file("fstesta.txt")
delete_file("fstestb.txt")
write_file("fstesta.txt", "copying data", TEXT_MODE)
test_true("copy_file #1", copy_file("fstesta.txt", "fstestb.txt", 1))
test_true("copy_file #2", sequence( dir("fstestb.txt"))) -- 'b' should now exist
test_true("copy_file #3", sequence( dir("fstesta.txt"))) -- 'a' should still exist
test_false("copy_file #4", copy_file("fstesta.txt", "fstestb.txt")) -- should not overwrite existing file
test_false("copy_file #5", copy_file("fstesta.txt", "fstestb.txt", 0)) -- should not overwrite existing file
delete_file("fstesta.txt")
delete_file("fstestb.txt")

-- filebase()
test_equal( "file base", "readme", filebase("/opt/euphoria/readme.txt") )

-- file_type()
test_equal( "file_type() directory", FILETYPE_DIRECTORY, file_type( current_dir() ))

-- canonical_path()
test_equal( "canonical_path() #1", current_dir() & SLASH & "t_filesys.e", canonical_path( "t_filesys.e" ) )
test_equal( "canonical_path() #2", current_dir() & SLASH & "t_filesys.e", canonical_path( `"t_filesys.e"` ) )
test_equal( "canonical_path() #3", current_dir() & SLASH, canonical_path( current_dir() & SLASH & '.' & SLASH ) )

sequence home = getenv("HOME")
if home[$] != SLASH then
	home &= SLASH
end if
test_equal( "canonical_path() #4", home, canonical_path("~"))
test_equal( "canonical_path() #5", current_dir() & SLASH, canonical_path( current_dir() & SLASH & "foo" & SLASH & ".." & SLASH ) )

ifdef UNIX then
	test_equal( "canonical_path() #6", current_dir() & SLASH & "UPPERNAME", canonical_path( "UPPERNAME",,1 ))
	test_equal( "canonical_path() #7", current_dir() & SLASH & "UPPERNAME", canonical_path( "UPPERNAME",,0 ))
end ifdef

ifdef WINDOWS then
	test_equal( "canonical_path() #6", lower(current_dir() & SLASH & "UPPERNAME"), canonical_path( "UPPERNAME",,1 ))
	test_equal( "canonical_path() #7",       current_dir() & SLASH & "UPPERNAME",  canonical_path( "UPPERNAME",,0 ))
end ifdef

test_true( "simple disk_size test", sequence( disk_size( "." ) ) )

sequence walk_data = {}
function test_walk( sequence path_name, sequence item )
	walk_data = append( walk_data, { path_name, item[D_NAME] } )
	return 0
end function

procedure dir_tests()
	if file_exists( "filesyse_dir" ) then
		test_true( "remove existing testing directory", remove_directory( "filesyse_dir", 1))
		
	end if
	
	test_false( "Bad name #1", create_directory( ".." ) )
	test_false( "Bad name #2", create_directory( "" ) )
	
	test_false( "testing directory is gone", file_exists( "filesyse_dir" ) )
	test_true( "create filesyse_dir", create_directory( canonical_path( "filesyse_dir" ) & SLASH ) )
	
	test_true( "chdir filesyse_dir", chdir( "filesyse_dir" ) )
	sequence expected_walk_data = {}

	for d = 1 to 2 do
		sequence dirname = sprintf("directory%d", d )
		test_true( "create dir " & dirname, create_directory( dirname ) )
		test_true( "chdir " & dirname, chdir( dirname ))
		expected_walk_data = append( expected_walk_data, { "filesyse_dir", dirname } )
		for f = 1 to 2 do
			sequence filename = sprintf("file%d",f)
			create_file( filename)
			test_true( "File exists " & filename, file_exists(filename))
			expected_walk_data = append( expected_walk_data, { "filesyse_dir" & SLASH & dirname, filename } )
		end for
		test_true( "back to filesyse_dir", chdir( ".." ))
	end for
	create_file( "test-file")
	test_true( "test-file exists", file_exists("test-file"))
	
	expected_walk_data = append( expected_walk_data, {"filesyse_dir", "test-file"})
	
	test_true("back to tests", chdir("..") )
	
	test_equal( "walk dir", 0, walk_dir( "filesyse_dir", routine_id("test_walk"), 1 ) )
	
	test_equal( "test walk_dir results", expected_walk_data, walk_data )
	
	sequence test_dir_size = dir_size( "filesyse_dir" )
	test_equal( "dir size dir count", 2, test_dir_size[COUNT_DIRS] )
	test_equal( "dir size file count", 1, test_dir_size[COUNT_FILES] )
	
	test_not_equal( "clear directory", 0, clear_directory( "filesyse_dir", 0 ) )
	test_true( "remove testing directory", remove_directory( "filesyse_dir", 1 ) )
end procedure
dir_tests()

test_report()
