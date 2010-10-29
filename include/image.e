-- (c) Copyright 2007 Rapid Deployment Software - See License.txt
--
-- Euphoria 3.1
-- Graphical Image routines

include machine.e
include graphics.e
include misc.e

constant BMPFILEHDRSIZE = 14
constant OLDHDRSIZE = 12, NEWHDRSIZE = 40
constant EOF = -1

-- error codes returned by read_bitmap(), save_bitmap() and save_screen()
global constant BMP_SUCCESS = 0,
		BMP_OPEN_FAILED = 1,
		BMP_UNEXPECTED_EOF = 2,
		BMP_UNSUPPORTED_FORMAT = 3,
		BMP_INVALID_MODE = 4
	 
integer fn, error_code

function get_word()
-- read 2 bytes
    integer lower, upper
    
    lower = getc(fn)
    upper = getc(fn)
    if upper = EOF then
	error_code = BMP_UNEXPECTED_EOF
    end if
    return upper * 256 + lower
end function

function get_dword()
-- read 4 bytes
    integer lower, upper
    
    lower = get_word()
    upper = get_word()
    return upper * 65536 + lower
end function

function get_c_block(integer num_bytes)
-- read num_bytes bytes
    sequence s
    
    s = repeat(0, num_bytes)
    for i = 1 to num_bytes do
	s[i] = getc(fn)
    end for
    if s[$] = EOF then
	error_code = BMP_UNEXPECTED_EOF
    end if
    return s
end function

function get_rgb(integer set_size)
-- get red, green, blue palette values
    integer red, green, blue
    
    blue = getc(fn)
    green = getc(fn)
    red = getc(fn)
    if set_size = 4 then
	if getc(fn) then
	end if
    end if
    return {red, green, blue}
end function

function get_rgb_block(integer num_dwords, integer set_size)
-- reads palette 
    sequence s

    s = {}
    for i = 1 to num_dwords do
	s = append(s, get_rgb(set_size))
    end for
    if s[$][3] = EOF then
	error_code = BMP_UNEXPECTED_EOF
    end if
    return s
end function

function row_bytes(atom BitCount, atom Width)
-- number of bytes per row of pixel data
    return floor(((BitCount * Width) + 31) / 32) * 4
end function

function unpack(sequence image, integer BitCount, integer Width, integer Height)
-- unpack the 1-d byte sequence into a 2-d sequence of pixels
    sequence pic_2d, row, bits
    integer bytes, next_byte, byte
    
    pic_2d = {}
    bytes = row_bytes(BitCount, Width)
    next_byte = 1
    for i = 1 to Height do
	row = {}
	if BitCount = 1 then
	    for j = 1 to bytes do
		byte = image[next_byte]
		next_byte += 1
		bits = repeat(0, 8)
		for k = 8 to 1 by -1 do
		    bits[k] = and_bits(byte, 1)
		    byte = floor(byte/2)
		end for
		row &= bits
	    end for
	elsif BitCount = 2 then
	    for j = 1 to bytes do
		byte = image[next_byte]
		next_byte += 1
		bits = repeat(0, 4)
		for k = 4 to 1 by -1 do
		    bits[k] = and_bits(byte, 3)
		    byte = floor(byte/4)
		end for
		row &= bits
	    end for
	elsif BitCount = 4 then
	    for j = 1 to bytes do
		byte = image[next_byte]
		row = append(row, floor(byte/16))
		row = append(row, and_bits(byte, 15))
		next_byte += 1
	    end for
	elsif BitCount = 8 then
	    row = image[next_byte..next_byte+bytes-1]
	    next_byte += bytes
	else
	    error_code = BMP_UNSUPPORTED_FORMAT
	    exit
	end if
	pic_2d = prepend(pic_2d, row[1..Width])
    end for
    return pic_2d
end function

global function read_bitmap(sequence file_name)
-- read a bitmap (.BMP) file into a 2-d sequence of sequences (image)
-- return {palette,image}   
    atom Size 
    integer Type, Xhot, Yhot, Planes, BitCount
    atom Width, Height, Compression, OffBits, SizeHeader, 
	 SizeImage, XPelsPerMeter, YPelsPerMeter, ClrUsed,
	 ClrImportant, NumColors
    sequence Palette, Bits, two_d_bits

    error_code = 0
    fn = open(file_name, "rb")
    if fn = -1 then
	return BMP_OPEN_FAILED
    end if
    Type = get_word()
    Size = get_dword()
    Xhot = get_word()
    Yhot = get_word()
    OffBits = get_dword()
    SizeHeader = get_dword()

    if SizeHeader = NEWHDRSIZE then
	Width = get_dword()
	Height = get_dword()
	Planes = get_word()
	BitCount = get_word()
	Compression = get_dword()
	if Compression != 0 then
	    close(fn)
	    return BMP_UNSUPPORTED_FORMAT
	end if
	SizeImage = get_dword()
	XPelsPerMeter = get_dword()
	YPelsPerMeter = get_dword()
	ClrUsed = get_dword()
	ClrImportant = get_dword()
	NumColors = (OffBits - SizeHeader - BMPFILEHDRSIZE) / 4
	if NumColors < 2 or NumColors > 256 then
	    close(fn)
	    return BMP_UNSUPPORTED_FORMAT
	end if
	Palette = get_rgb_block(NumColors, 4) 
    
    elsif SizeHeader = OLDHDRSIZE then 
	Width = get_word()
	Height = get_word()
	Planes = get_word()
	BitCount = get_word()
	NumColors = (OffBits - SizeHeader - BMPFILEHDRSIZE) / 3
	SizeImage = row_bytes(BitCount, Width) * Height
	Palette = get_rgb_block(NumColors, 3) 
    else
	close(fn)
	return BMP_UNSUPPORTED_FORMAT
    end if
    if Planes != 1 or Height <= 0 or Width <= 0 then
	close(fn)
	return BMP_UNSUPPORTED_FORMAT
    end if
    Bits = get_c_block(row_bytes(BitCount, Width) * Height)
    close(fn)
    two_d_bits = unpack(Bits, BitCount, Width, Height)
    if error_code then
	return error_code 
    end if
    return {Palette, two_d_bits}
end function

type graphics_point(sequence p)
    return length(p) = 2 and p[1] >= 0 and p[2] >= 0
end type

type text_point(sequence p)
    return length(p) = 2 and p[1] >= 1 and p[2] >= 1 
	   and p[1] <= 200 and p[2] <= 500 -- rough sanity check
end type

constant COLOR_TEXT_MEMORY = #B8000,
	  MONO_TEXT_MEMORY = #B0000

constant M_GET_DISPLAY_PAGE = 28,
	 M_SET_DISPLAY_PAGE = 29,
	 M_GET_ACTIVE_PAGE = 30,
	 M_SET_ACTIVE_PAGE = 31

constant BYTES_PER_CHAR = 2

type page_number(integer p)
    return p >= 0 and p <= 7
end type

global function get_display_page()
-- return current page# mapped to the monitor   
    return machine_func(M_GET_DISPLAY_PAGE, 0)
end function

constant M_GET_SCREEN_CHAR = 58,
	 M_PUT_SCREEN_CHAR = 59

type positive_atom(atom x)
    return x >= 1
end type

global function get_screen_char(positive_atom line, positive_atom column)
-- returns {character, attributes} of the single character
-- at the given (line, column) position on the screen  
    return machine_func(M_GET_SCREEN_CHAR, {line, column})
  
end function

global procedure put_screen_char(positive_atom line, positive_atom column, 
				 sequence char_attr)
-- stores {character, attributes, character, attributes, ...} 
-- of 1 or more characters at position (line, column) on the screen
    atom scr_addr
    sequence vc
    integer overflow
   
	machine_proc(M_PUT_SCREEN_CHAR, {line, column, char_attr})
end procedure

global procedure display_text_image(text_point xy, sequence text)
-- Display a text image at line xy[1], column xy[2] in any text mode.
-- N.B. coordinates are {line, column} with {1,1} at the top left of screen
-- Displays to the active text page.
    atom scr_addr
    integer screen_width, extra_col2, extra_lines
    sequence vc, one_row
    
    vc = video_config()
    if xy[1] < 1 or xy[2] < 1 then
	return -- bad starting point
    end if
    extra_lines = vc[VC_LINES] - xy[1] + 1 
    if length(text) > extra_lines then
	if extra_lines <= 0 then
	    return -- nothing to display
	end if
	text = text[1..extra_lines] -- truncate
    end if
    extra_col2 = 2 * (vc[VC_COLUMNS] - xy[2] + 1)
    for row = 1 to length(text) do
	one_row = text[row]
	if length(one_row) > extra_col2 then
	    if extra_col2 <= 0 then
		return -- nothing to display
	    end if
	    one_row = one_row[1..extra_col2] -- truncate
	end if
	end for
end procedure

global function save_text_image(text_point top_left, text_point bottom_right)
-- Copy a rectangular block of text out of screen memory,
-- given the coordinates of the top-left and bottom-right corners.
-- Reads from the active text page.
	sequence image, row_chars, vc

	image = {}
	for row = top_left[1] to bottom_right[1] do
		row_chars = {}
		for col = top_left[2] to bottom_right[2] do
			row_chars &= machine_func(M_GET_SCREEN_CHAR, {row, col})
		end for

		image = append(image, row_chars)
	end for
	return image
end function


-- save_screen() and related functions were written by 
-- Junko C. Miura of Rapid Deployment Software.  

integer numXPixels, numYPixels, bitCount, numRowBytes
integer startXPixel, startYPixel, endYPixel

type region(object r)
    -- a region on the screen
    if atom(r) then
	return r = 0
    else
	return length(r) = 2 and graphics_point(r[1]) and
				 graphics_point(r[2])
    end if
end type

type two_seq(sequence s)
    -- a two element sequence, both elements are sequences
    return length(s) = 2 and sequence(s[1]) and sequence(s[2])
end type

procedure putBmpFileHeader(integer numColors)
    integer offBytes
    
    -- calculate bitCount, ie, color bits per pixel, (1, 2, 4, 8, or error) 
    if numColors = 256 then
	bitCount = 8            -- 8 bits per pixel
    elsif numColors = 16 then
	bitCount = 4            -- 4 bits per pixel
    elsif numColors = 4 then
	bitCount = 2            -- 2 bits per pixel 
    elsif numColors = 2 then
	bitCount = 1            -- 1 bit per pixel
    else 
	error_code = BMP_INVALID_MODE
	return
    end if

    puts(fn, "BM")  -- file-type field in the file header
    offBytes = 4 * numColors + BMPFILEHDRSIZE + NEWHDRSIZE
    numRowBytes = row_bytes(bitCount, numXPixels)
    -- put total size of the file
    puts(fn, int_to_bytes(offBytes + numRowBytes * numYPixels))
 
    puts(fn, {0, 0, 0, 0})              -- reserved fields, must be 0
    puts(fn, int_to_bytes(offBytes))    -- offBytes is the offset to the start
					--   of the bitmap information
    puts(fn, int_to_bytes(NEWHDRSIZE))  -- size of the secondary header
    puts(fn, int_to_bytes(numXPixels))  -- width of the bitmap in pixels
    puts(fn, int_to_bytes(numYPixels))  -- height of the bitmap in pixels
    
    puts(fn, {1, 0})                    -- planes, must be a word of value 1
    
    puts(fn, {bitCount, 0})     -- bitCount
    
    puts(fn, {0, 0, 0, 0})      -- compression scheme
    puts(fn, {0, 0, 0, 0})      -- size image, not required
    puts(fn, {0, 0, 0, 0})      -- XPelsPerMeter, not required 
    puts(fn, {0, 0, 0, 0})      -- YPelsPerMeter, not required
    puts(fn, int_to_bytes(numColors))   -- num colors used in the image
    puts(fn, int_to_bytes(numColors))   -- num important colors in the image
end procedure

procedure putOneRowImage(sequence x, integer numPixelsPerByte, integer shift)
-- write out one row of image data
    integer  j, byte, numBytesFilled
	
    x &= repeat(0, 7)   -- 7 zeros is safe enough
	
    numBytesFilled = 0
    j = 1
    while j <= numXPixels do
	byte = x[j]
	for k = 1 to numPixelsPerByte - 1 do
	    byte = byte * shift + x[j + k]
	end for
    
	puts(fn, byte)
	numBytesFilled += 1
	j += numPixelsPerByte
    end while
    
    for m = 1 to numRowBytes - numBytesFilled do
	puts(fn, 0)
    end for
end procedure

procedure putColorTable(integer numColors, sequence pal)
-- Write color table information to the .BMP file. 
-- palette data is given as a sequence {{r,g,b},..,{r,g,b}}, where each
-- r, g, or b value is 0 to 255. 

    for i = 1 to numColors do
	puts(fn, pal[i][3])     -- blue first in .BMP file
	puts(fn, pal[i][2])     -- green second 
	puts(fn, pal[i][1])     -- red third
	puts(fn, 0)             -- reserved, must be 0
    end for
end procedure

procedure putImage1(sequence image)
-- Write image data packed according to the bitCount information, in the order
-- last row ... first row. Data for each row is padded to a 4-byte boundary.
-- Image data is given as a 2-d sequence in the order first row... last row.
    object   x
    integer  numPixelsPerByte, shift
    
    numPixelsPerByte = 8 / bitCount
    shift = power(2, bitCount)
    for i = numYPixels to 1 by -1 do
	x = image[i]
	if atom(x) then
	    error_code = BMP_INVALID_MODE
	    return
	elsif length(x) != numXPixels then
	    error_code = BMP_INVALID_MODE
	    return
	end if
	putOneRowImage(x, numPixelsPerByte, shift) 
    end for
end procedure

global function save_bitmap(two_seq palette_n_image, sequence file_name)
-- Create a .BMP bitmap file, given a palette and a 2-d sequence of sequences.
-- The opposite of read_bitmap().
    sequence color, image
    integer numColors

    error_code = BMP_SUCCESS
    fn = open(file_name, "wb")
    if fn = -1 then
	return BMP_OPEN_FAILED
    end if
    
    color = palette_n_image[1]
    image = palette_n_image[2]
    numYPixels = length(image)
    numXPixels = length(image[1])   -- assume the same length with each row
    numColors = length(color)
    
    putBmpFileHeader(numColors)
    
    if error_code = BMP_SUCCESS then
	putColorTable(numColors, color) 
	putImage1(image)
    end if
    close(fn)
    return error_code
end function


