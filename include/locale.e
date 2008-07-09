-- (c) Copyright 2008 Rapid Deployment Software - See License.txt
--
--****
-- ==  Locale Routines
-- **Page Contents**
--
-- <<LEVELTOC depth=2>>
-- 

include dll.e
include machine.e
include error.e
include datetime.e as dt
include text.e
include io.e
include map.e as m
include localeconv.e as lcc

------------------------------------------------------------------------------------------
--
-- Local Constants
--
------------------------------------------------------------------------------------------

constant P = C_POINTER, I = C_INT, D = C_DOUBLE

------------------------------------------------------------------------------------------
--
-- Local Variables
--
------------------------------------------------------------------------------------------

m:map lang
lang = m:new()

object lang_path
lang_path = 0

--****
-- === Message translation functions
--

--**
-- Set the language path.
--
-- Parameters:
-- 		# ##pp##: an object, either an actual path or an atom.
--
-- Comments:
--	When the language path is not set, and it is unset by default, [[:set]]() does not load any language file.
-- See Also:
--		[[:set]]
export procedure set_lang_path(object pp)
	lang_path = pp
end procedure

--**
-- Get the language path.
--
-- Returns:
-- 		An **object**, the current language path.
-- See Also:
--		[[:get_lang_path]]
export function get_lang_path()
	return lang_path
end function

--**
-- Load a language file.
--
-- Parameters:
-- 		# ##filename##: a sequence, the //base// name of the fie to load.
--
-- Returns:
--		An **integer**: 0 on failure, 1 on success.
-- Comments:
-- The language file must be made of lines which either in the form
-- {{{
-- key value
-- }}}
-- withhout any space in the key part, or else start with a ~#~ character, in which case they are treated as comments. Leading whitespace does not count.
-- See Also:
--		[[:w]]
export function lang_load(sequence filename)
	object lines
	sequence line, key, msg
	integer sp, cont -- continuation

	cont = 0
	filename &= ".lng"

	lines = read_lines(filename)
	if atom(lines) then
		return 0  -- TODO: default to English?
	end if

	lang = m:new() -- clear any old data

	for i = 1 to length(lines) do
		line = trim(lines[i], " \r\n")
		if cont then
			msg &= trim_tail(line, " &")
			if line[$] != '&' then
				cont = 0
				lang = m:put(lang, key, msg)
			else
				msg &= '\n'
			end if
		elsif length(line) > 0 and line[1] != '#' then
			sp = find(32, line)
			if sp then 
				if line[$] = '&' then
					cont = 1
					key = line[1..sp-1]
					msg = trim_tail(line[sp+1..$], " &") & '\n'
				else
					lang = m:put(lang, line[1..sp-1], line[sp+1..$])
				end if
			else
				crash("Malformed Language file %s on line %d", {filename, i})
			end if
		end if
	end for

	return 1
end function

--**
-- Translates a word, using the current language file.
--
-- Parameters:
-- 		# ##word##: a sequence, the word to trnslate.
-- Returns:
--		A **sequence**, the value associated to the key ##word##.
-- Comments:
-- "" is returned if no translation was found.
-- See Also:
-- 		[[:set]], [[:lang_load]]
export function w(sequence word)
	return m:get(lang, word, "")
end function

------------------------------------------------------------------------------------------
--
-- Library Open/Checking
--
------------------------------------------------------------------------------------------

atom lib, lib2
integer LC_ALL, LC_COLLATE, LC_CTYPE, LC_MONETARY, LC_NUMERIC,
	LC_TIME, LC_MESSAGES, f_strfmon, f_strfnum

ifdef WIN32 then
	lib = open_dll("MSVCRT.DLL")
	lib2 = open_dll("KERNEL32.DLL")
	f_strfmon = define_c_func(lib2, "GetCurrencyFormatA", {I, I, P, P, P, I}, I)
	f_strfnum = define_c_func(lib2, "GetNumberFormatA", {I, I, P, P, P, I}, I)
	LC_ALL      = 0
	LC_COLLATE  = 1
	LC_CTYPE    = 2
	LC_MONETARY = 3
	LC_NUMERIC  = 4
	LC_TIME     = 5
	LC_MESSAGES = 6

elsifdef LINUX then

	lib = open_dll("")
	f_strfmon = define_c_func(lib, "strfmon", {P, I, P, D}, I)
	f_strfnum = -1
	LC_ALL      = 6
	LC_CTYPE    = 0
	LC_NUMERIC  = 1
	LC_TIME     = 2
	LC_COLLATE  = 3
	LC_MONETARY = 4
	LC_MESSAGES = 5

elsifdef FREEBSD then

	lib = open_dll("libc.so")
	f_strfmon = define_c_func(lib, "strfmon", {P, I, P, D}, I)
	f_strfnum = -1

	LC_ALL      = 0
	LC_COLLATE  = 1
	LC_CTYPE    = 2
	LC_MONETARY = 3
	LC_NUMERIC  = 4
	LC_TIME     = 5
	LC_MESSAGES = 6

elsifdef OSX then

	lib = open_dll("libc.dylib")
	f_strfmon = define_c_func(lib, "strfmon", {P, I, P, D}, I)
	f_strfnum = -1

	LC_ALL      = 0
	LC_COLLATE  = 1
	LC_CTYPE    = 2
	LC_MONETARY = 3
	LC_NUMERIC  = 4
	LC_TIME     = 5
	LC_MESSAGES = 6
  
else

	crash("locale.e requires Windows, Linux, FreeBSD or OS X", {})

end ifdef

--****
-- === Time/Number Translation

constant
	f_setlocale = define_c_func(lib, "setlocale", {I, P}, P),
	f_strftime = define_c_func(lib, "strftime", {P, I, P, P}, I)

--**
-- Set the computer locale, and possibly loas appropriate translation file.
--
-- Parameters:
--		# ##new_locale##: a sequence representing a nex locale.
--
-- Returns:
--		An **integer**, either 0 on failure or 1 on success.
--
-- Comments:
-- Locale strings have the following format: xx_YY or xx_YY.xyz .
-- The xx part refers to a culture, or main language/script. For instance, "en" refers to english, "de" refers to german, and so on. For some language, a script may be specified, like in "mn_Cyrl_MN" (mongolian in cyrillic transcription).
-- The YY part refers to a subculture, or variant, of the main language. For instance, "fr_FR" refers to metropolitan France, while "fr_BE" refers to the variant spoken in Wallonie, the french speaking region of Belgium.
-- The optional .xyz part specifies an encoding, like .utf8. This is required in some cases.
export function set(sequence new_locale)
	atom pLocale, ign
	
	new_locale = lcc:decanonical(new_locale)
	pLocale = allocate_string(new_locale)
	ign = c_func(f_setlocale, {LC_MONETARY, pLocale})
	ign = c_func(f_setlocale, {LC_NUMERIC, pLocale})
	ign = c_func(f_setlocale, {LC_ALL, pLocale})

	if sequence(lang_path) then
		return lang_load(new_locale)
	end if

	return (ign != NULL)
end function

--**
-- Get current locale string
--
-- Returns:
--		A **sequence**, a locaale string.
--
-- See Also:
--		[[:set]]
export function get()
	sequence r
	atom p

	p = c_func(f_setlocale, {LC_ALL, NULL})
	if p = NULL then
		return ""
	end if

	r = peek_string(p)
	r = lcc:canonical(r)

	return r
end function

--**
-- Converts an amount of currency into a string representing that amount.
--
-- Parameters:
--		# ##amount##: an atom, the value to write out.
--
-- Returns:
-- 		A **sequence**, a string that writes out ##amoubt## of current currency.
-- Example 1:
-- <eucode>
-- -- Assuming an en_US locale
-- ?money(1020.5) -- returns"$1,020.50"
-- </eucode>
-- See Also:
--		[[:set]], [[:number]]
export function money(atom amount)
	sequence result
	integer size
	atom pResult, pTmp

	ifdef UNIX then
		pResult = allocate(4 * 160)
		pTmp = allocate_string("%n")
		size = c_func(f_strfmon, {pResult, 4 * 160, pTmp, amount})
	else
		pResult = allocate(4 * 160)
		pTmp = allocate_string(sprintf("%.8f", {amount}))
		size = c_func(f_strfmon, {LC_ALL, 0, pTmp, NULL, pResult, 4 * 160})
	end ifdef

	result = peek_string(pResult)
	free(pResult)
	free(pTmp)

	return result
end function

--**
-- Converts a number into a string representing that number.
--
-- Parameters:
--		# ##num##: an atom, the value to write out.
--
-- Returns:
-- 		A **sequence**, a string that writes out ##num##.
-- Example 1:
-- <eucode>
-- -- Assuming an en_US locale
-- ?number(1020.5) -- returns"1,020.50"
-- </eucode>
-- See Also:
--		[[:set]], [[:money]]
export function number(atom num)
	sequence result
	integer size
	atom pResult, pTmp

	ifdef UNIX then
		pResult = allocate(4 * 160)
		pTmp = allocate_string("%!n")
		size = c_func(f_strfmon, {pResult, 4 * 160, pTmp, num})
	else
		pResult = allocate(4 * 160)
		pTmp = allocate_string(sprintf("%.8f", {num}))
		size = c_func(f_strfnum, {LC_ALL, 0, pTmp, NULL, pResult, 4 * 160})
	end ifdef

	result = peek_string(pResult)
	free(pResult)
	free(pTmp)

	return result
end function

function mk_tm_struct(dt:datetime dtm)
	atom pDtm

	pDtm = allocate(36)
	poke4(pDtm,    dtm[SECOND])        -- int tm_sec
	poke4(pDtm+4,  dtm[MINUTE])        -- int tm_min
	poke4(pDtm+8,  dtm[HOUR])          -- int tm_hour
	poke4(pDtm+12, dtm[DAY])           -- int tm_mday
	poke4(pDtm+16, dtm[MONTH] - 1)     -- int tm_mon
	poke4(pDtm+20, dtm[YEAR] - 1900)   -- int tm_year
	poke4(pDtm+24, dt:dow(dtm) - 1)    -- int tm_wday
	poke4(pDtm+28, dt:doy(dtm))        -- int tm_yday
	poke4(pDtm+32, 0)                  -- int tm_isdst

	return pDtm
end function

--**
-- Formats a date according to current locale.
--
-- Parameters:
--		# ##fmt##: A format string, as described in [[:format]]
--		# ##dtm##: the datetime to wrie out.
--
-- Returns:
--		A **sequence**, representing the formatted date.
-- Example 1:
-- <eucode>
--	include datetime.e
-- ?datetime("Today is a %A",dt:now())
-- </eucode>
-- See Also:
--		[[:format]]
export function datetime(sequence fmt, dt:datetime dtm)
	atom pFmt, pRes, pDtm
	integer size
	sequence res

	pDtm = mk_tm_struct(dtm)
	pFmt = allocate_string(fmt)
	pRes = allocate(1024)
	size = c_func(f_strftime, {pRes, 256, pFmt, pDtm})
	res = peek_string(pRes)
	free(pRes)
	free(pFmt)
	free(pDtm)

	return res
end function
