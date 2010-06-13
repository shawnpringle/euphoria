/*****************************************************************************/
/*      (c) Copyright - See License.txt       */
/*****************************************************************************/
/*                                                                           */
/*              Run Time Error Handler & Interactive Trace                   */
/*                                                                           */
/*****************************************************************************/

/******************/
/* Included files */
/******************/
#include <stdio.h>
#include <stdarg.h>
#include <setjmp.h>

#ifndef EUNIX
#  if !defined(EMINGW)
#    include <graph.h>
#    include <bios.h>
#  endif
#  include <conio.h>
#endif

#ifdef EUNIX
#include <sys/ioctl.h>
#endif
#ifdef EOSX
#include <unistd.h>
#endif

#include <signal.h>
#include <string.h>
#ifdef EWINDOWS
#include <windows.h>
extern HANDLE console_output;
#endif

#include "alldefs.h"
#include "be_runtime.h"
#include "global.h"
#include "task.h"

void GetViewPort(struct EuViewPort *vp);


/******************/
/* Local defines  */
/******************/
#define BASE_TRACE_LINE 1 
#define NUM_PROMPT_LINES 1
#define VAR_WIDTH 20
#define MAX_VAR_LINES 7
#define MAX_VARS_PER_LINE 6
#define MAX_TRACEBACK 100 /* maximum number of levels of traceback to show */

#ifdef EUNIX
#define FLIP_TO_MAIN 265  /* F1 */
#define FLIP_TO_DEBUG 266 /* F2 */
#define DOWN_ARROW 258

#else

#define FLIP_TO_MAIN 315  /* F1 */
#define FLIP_TO_DEBUG 316 /* F2 */
#define DOWN_ARROW 336
#endif

struct display_slot {
	symtab_ptr sym;
	long time_stamp;
	object value_on_screen;
};

/**********************/
/* Imported variables */
/**********************/
extern int tcb_size;
extern struct tcb *tcb;
extern int current_task;
extern int warning_count;
extern char **warning_list;
extern int crash_count;
extern symtab_ptr *e_routine;
extern int **jumptab;
extern char *last_traced_line;
extern int Executing;
extern int gameover;
extern int current_screen;
extern int allow_break;
extern int control_c_count; 
#ifdef EUNIX
extern unsigned current_fg_color, current_bg_color;
extern int consize_ioctl;
#endif
extern int bound;
extern int print_chars;
extern int stack_size;
extern int screen_line, screen_col;
extern int screen_lin_addr;
extern int max_stack_per_call;
extern object_ptr expr_stack; 
extern object_ptr expr_top;
extern unsigned char TempBuff[];
extern object_ptr frame_base;
extern int *tpc;
extern object_ptr *frame_base_ptr;
extern jmp_buf env;
extern struct sline *slist;
extern char **file_name;
extern unsigned line_number;
extern long gline_number;
extern int start_line;
extern int TraceBeyond;
extern int TraceStack;
extern symtab_ptr TopLevelSub;
extern int TraceOn;
extern IFILE TempErrFile;
extern char *TempErrName;
extern struct videoconfig config;
extern int wrap_around;
extern int in_from_keyb;
extern char *crash_msg;

#ifdef EWINDOWS
extern void SaveNormal();
extern void SaveTrace();
extern void RestoreNormal();
extern void RestoreTrace();
#endif

#ifdef EUNIX
extern struct char_cell screen_image[MAX_LINES][MAX_COLS];
extern struct char_cell alt_image_main[MAX_LINES][MAX_COLS];
extern struct char_cell alt_image_debug[MAX_LINES][MAX_COLS];
#endif

/**********************/
/* Exported variables */
/**********************/
//int caught_interrupt = FALSE;   /* did we receive an interrupt? */
int traced_lines = FALSE;
int *TraceLineBuff = NULL;      /* place to store traced lines */
int TraceLineSize;              /* size of buffer */
int TraceLineNext = 0;          /* place to put next line */
int color_trace = 0;            /* display trace screen in multiple colors */
int file_trace;                 /* log statements to ctrace.out */
int trace_enabled = TRUE;       /* flag to disable tracing */
char *type_error_msg = "\ntype_check failure, ";   /* changeable message */

/*******************/
/* Local variables */
/*******************/
static char FErrBuff[300];
static int MainCol;   /* Main foreground color */
static int MainBkCol; /* Main background color */
//#ifdef EUNIX
//static WINDOW *var_scr = NULL;      // variable display screen
//static WINDOW *debug_scr = NULL;    // debug screen
//static WINDOW *main_scr  = NULL;    // main screen
//#endif
static char *DebugScreenSave = NULL;   /* place to save debug screen */
static struct rccoord MainPos; /* text position save area */
static int MainWrap;  /* Main wrap mode */
static int main_screen_col = 1;
static int debug_screen_col = 1;
static int main_screen_line = 1;
static int debug_screen_line = 1;
static int first_debug;           /* first time into debug screen */
static long trace_line;      /* current traced line */

static long highlight_line;     /* current line on debug screen */

static struct display_slot display_list[MAX_VAR_LINES * MAX_VARS_PER_LINE]; 
								/* list of display slots */
static long tstamp = 1; /* time stamp for deleting vars on display */
static IFILE conin; 

/**********************/
/* Declared functions */
/**********************/
symtab_ptr Locate();
#include "alloc.h"
static void screen_blank();
static void SaveDebugImage();
static void RestoreDebugImage();
struct rccoord GetTextPositionP();
static void ShowName();
void UpdateGlobals();
void EraseSymbol();
symtab_ptr RTLookup();

/*********************/
/* Defined functions */
/*********************/

void OpenErrFile()
// open the error diagnostics file - normally "ex.err"
{
	int n;

	if (TempErrFile == NULL)	
		TempErrFile = iopen(TempErrName, "w");
	if (TempErrFile == NULL) {
		if (strlen(TempErrName) > 0) {
			screen_output(stderr, "Can't create error message file: ");
			screen_output(stderr, TempErrName);
			screen_output(stderr, "\n");
			n = NumberOpen();
			if (n > 13) {
#define OpenErrFile_buff_len (40)
				char buff[OpenErrFile_buff_len];
				snprintf(buff, OpenErrFile_buff_len, "Too many open files? (%d)\n", n);
				buff[OpenErrFile_buff_len - 1] = 0; // ensure NULL
				screen_output(stderr, buff);
			}
		}
		Cleanup(1);
	}
}

void InitTraceWindow()
{
	TraceLineSize = 25;
	TraceLineBuff = (int *)EMalloc(TraceLineSize * sizeof(int));
	memset(TraceLineBuff, 0, TraceLineSize * sizeof(int));
	TraceLineNext = 0;
}

void InitDebug()
{
	first_debug = TRUE;
	trace_line = 0;
}

static void set_bk_color(int c)
/* set the background color for color displays 
   otherwise just leave the background as black */
{
	int col;
	
	if (color_trace && COLOR_DISPLAY) {
		if (TEXT_MODE) {
			col = c;
		}
		else {
			col = _WHITE;
		}
	}
	else {
		col = _BLACK;
	}
	if (col == _WHITE)
		col = 7;
	else if (col == _BLACK)
		col = 0; 
#ifdef EUNIX
	else if (col == _BLUE)
		col = 4;
	else if (col == _YELLOW)
		col = 11;
	else if (col == _CYAN)
		col = 6;
	else if (col == _BROWN)
		col = 3;
#else
	else if (col == _BLUE)
		col = 1;
	else if (col == _YELLOW)
		col = 14;
	else if (col == _CYAN)
		col = 3;
	else if (col == _BROWN)
		col = 6;
#endif
#ifdef EXTRA_CHECK
	else
		RTInternal("bad color!");
#endif
	SetBColor(MAKE_INT(col));
}

#ifndef BACKEND
static int OffScreen(long line_num)
/* return TRUE if line_num is off (or almost off) the TRACE window */
{
	long new_highlight_line;
	struct EuViewPort vp;

	GetViewPort( &vp );
	new_highlight_line = (long)highlight_line + line_num - trace_line;    
	if (new_highlight_line >= vp.num_trace_lines + BASE_TRACE_LINE - 1 || 
		new_highlight_line <= BASE_TRACE_LINE)
		return TRUE;
	else
		return FALSE;
}

static void DisplayLine(long n, int highlight)
/* display line n, possibly with highlighting */
{
	char *line;
	int string_color;
	int text, brief;
	
	text = TEXT_MODE;
	brief = (!text) && config.numxpixels <= 320;
	set_text_color(0);
	if (highlight) {
		string_color = 10;
		if (text) set_bk_color(_CYAN);
		snprintf(TempBuff, TEMP_SIZE, brief ? ">" : "%5u==>", slist[n].line);
		TempBuff[TEMP_SIZE-1] = 0; // ensure NULL
	}
	else {
		string_color = 2;
		if (text) set_bk_color(_WHITE);
		snprintf(TempBuff, TEMP_SIZE, brief ? " " : "%5u:  ", slist[n].line);
		TempBuff[TEMP_SIZE-1] = 0; // ensure NULL
	}
	line = slist[n].src; 
	if (slist[n].options & (OP_PROFILE_STATEMENT | OP_PROFILE_TIME))
		line += 4;
	if (line[0] == END_OF_FILE_CHAR) {
#ifdef EUNIX
		append_string(TempBuff, "\376\n", TEMP_SIZE - strlen(TempBuff) - 1);
#else
		append_string(TempBuff, "\021\n", TEMP_SIZE - strlen(TempBuff) - 1);
#endif
		screen_output(NULL, TempBuff);
	}
	else {
		size_t bufsize;
		long cb;
		
		bufsize = TEMP_SIZE - strlen(TempBuff) - 1;
		cb = append_string(TempBuff, line, bufsize);
		if (cb >= 0) {
			// Add EOL to line data
			copy_string(TempBuff + strlen(TempBuff), "\n", bufsize - cb);
		}
		else {
			// data was truncated, so force EOL at end of buffer.
			copy_string(TempBuff + TEMP_SIZE - 2, "\n", 2); // will end in \0
		}
		
		if (color_trace && COLOR_DISPLAY) 
			DisplayColorLine(TempBuff, string_color);
		else 
			screen_output(NULL, TempBuff);
	}
}

#define BLANK_SIZE 20
static char blanks[BLANK_SIZE+1]={' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
								  ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
								  '\0'};
static int prev_file_no = -1;

static void Refresh(long line_num, int vars_too)
/* refresh trace lines centred at line_num */
{
	long first_line;
	long i;
	struct EuViewPort vp;
	
#ifdef EWINDOWS
	int top_attrib, bottom_attrib;
#endif    
	GetViewPort( &vp );
	
	/* blank trace part of screen only */
	set_text_color(15);
	set_bk_color(_WHITE);     
#ifdef EWINDOWS
	if (color_trace && COLOR_DISPLAY) {
		top_attrib = (7<<4) + 15;
		bottom_attrib = (1<<4) + 15;
	}
	else {
		top_attrib = 0+7;
		bottom_attrib = 0+7;
	}
	EClearLines(2, 1 + vp.num_trace_lines, vp.columns, top_attrib);
	if (vars_too)
		EClearLines(2 + vp.num_trace_lines, vp.lines, vp.columns, bottom_attrib); 
#endif

#if defined(EUNIX)
	if (vars_too && !(TEXT_MODE)) {
		ClearScreen();
	}
	else {
		blank_lines(1, vp.num_trace_lines);
	
		if (vars_too) {
			if (TEXT_MODE)
				set_bk_color(_BLUE);
			blank_lines(1 + vp.num_trace_lines, 
						config.numtextrows - vp.num_trace_lines - 1);
		}
	}
#endif

	if (vars_too) {
		for (i = 0; i < vp.display_size; i++)
			display_list[i].value_on_screen = NOVALUE - 1;
	}           
	if (line_num < vp.num_trace_lines)
		first_line = 1;
	else if (line_num <= gline_number - vp.num_trace_lines + 1) {
		first_line = line_num - (vp.num_trace_lines / 2);
	}
	else
		first_line = gline_number - vp.num_trace_lines + 1;

	if (vars_too || slist[line_num].file_no != prev_file_no) {
		SetPosition(1, 1);
		set_text_color(15);
		if (TEXT_MODE)
			set_bk_color(_BROWN);

		snprintf(TempBuff, TEMP_SIZE,
				 " %.20s  F1=main  F2=trace  Enter  down-arrow  ?  q  Q  !",
				 name_ext(file_name[slist[line_num].file_no]));
		TempBuff[TEMP_SIZE-1] = 0; // ensure NULL
		buffer_screen();
		screen_output(NULL, TempBuff);
		screen_blank(NULL, vp.columns - 40);
		screen_output(NULL, " \n");
		flush_screen();
		prev_file_no = slist[line_num].file_no;
	}
	else
		SetPosition(2, 1);
		
	for (i = first_line; i <= gline_number && i < first_line + vp.num_trace_lines;
		 i++) {    
		if (slist[i].options & OP_TRACE) 
			DisplayLine(i, i == line_num);
		else 
			screen_output(NULL, "\n");
	}
	trace_line = line_num;
	highlight_line = line_num - first_line + BASE_TRACE_LINE;

	UpdateGlobals();
}


static void Move(long line_num)
/* update the inverse video line */
{
	/* reprint old line in normal video */
	SetPosition(highlight_line+1, 1);
	DisplayLine(trace_line, FALSE);

	highlight_line = highlight_line + line_num - trace_line;
	SetPosition(highlight_line+1, 1);
	DisplayLine(line_num, TRUE);

	trace_line = line_num;
}

static void ShowTraceLine(long line_num)
/* show the line of source to be executed next */
{
	if (trace_line == 0 || OffScreen(line_num)) { 
		Refresh(line_num, FALSE);
	}
	else {
		Move(line_num);
	}
}

#endif //not BACKEND

void MainScreen()
/* switch to main screen from debug screen */
/* caller must check if screen == MAIN_SCREEN already */
{
#ifndef BACKEND
#ifdef EXTRA_CHECK
	if (current_screen == MAIN_SCREEN)
		RTInternal("we're already in main screen");
#endif
	if (TEXT_MODE) {
		/* text mode */
#ifdef EWINDOWS
		RestoreNormal();
#endif
#ifdef EUNIX
		screen_copy(screen_image, alt_image_debug); // save debug screen
		screen_copy(alt_image_main, screen_image); // restore main screen
		screen_show();
#endif
	}
	SetPosition(MainPos.row, MainPos.col);
	debug_screen_col = screen_col;
	debug_screen_line = screen_line;
	screen_col = main_screen_col;
	screen_line = main_screen_line;

#ifdef EUNIX
	SetTColor(MainCol);
	SetBColor(MainBkCol);
#endif
	Wrap(MAKE_INT(MainWrap));
#endif // not BACKEND
	current_screen = MAIN_SCREEN;
}

static void LocateFail()
/* couldn't match tpc value to any routine */
{
	screen_output(stderr, "Runtime error (Traceback unavailable)");
	Cleanup(1);
}

#ifndef BACKEND
static void ClearSlot(int i)
/* mark a display slot as available */
{
	display_list[i].sym = NULL;
	display_list[i].time_stamp = 0;
	display_list[i].value_on_screen = NOVALUE - 1; // looks like a sequence
}


static void screen_blank(IFILE f, int nblanks)
/* output a string of blanks */
{
	while (nblanks >= BLANK_SIZE) {
		screen_output(f, blanks);
		nblanks -= BLANK_SIZE;
	}
	while (nblanks > 0) {
		screen_output(f, " ");
		nblanks--;
	}
}

static void SetVarPosition(int slot, int offset)
/* set cursor position to start of variable display slot */
{
	int var_line, var_pos;
	struct EuViewPort vp;

	GetViewPort( &vp );
	
	var_line = slot / vp.vars_per_line;
	var_pos = (slot - var_line * vp.vars_per_line) * VAR_WIDTH; 
	SetPosition(vp.num_trace_lines + BASE_TRACE_LINE + NUM_PROMPT_LINES 
				+ var_line + 1, var_pos + 1 + offset);
}

void ErasePrivates(symtab_ptr proc_ptr)
/* blank out any names on debug screen
   that match any privates of this proc/fn */
{
	register symtab_ptr sym;

	sym = proc_ptr->next;
	while (sym && (sym->scope == S_PRIVATE || sym->scope == S_LOOP_VAR)) {
		EraseSymbol(sym);
		sym = sym->next;
	}
}

void DisplayVar(symtab_ptr s_ptr, int user_requested)
/* display a variable and its value in debug area on screen */
{
	register int i, already_there;
	int col, found, inc, len_required;
	object val, screen_val;
	struct EuViewPort vp;
	
#define DV_len (40)
	char val_string[DV_len];
	int add_char, iv;
		
	GetViewPort( &vp );
	add_char = 0;
	if (TEXT_MODE)
		set_bk_color(_BLUE);

	val = s_ptr->obj;
	if (IS_SEQUENCE(val)) {
		inc = vp.vars_per_line;
	}
	else {
		if (val == NOVALUE) 
			copy_string( val_string, "<no value>", DV_len);
		else if (IS_ATOM_INT(val)) {
			iv = INT_VAL(val);
			snprintf(val_string,  DV_len, "%ld", iv);
			if (iv >= ' ' && iv <= 127)
				add_char = TRUE;
		}
		else 
			snprintf(val_string,  DV_len, "%.10g", DBL_PTR(val)->dbl);
		val_string[ DV_len - 1] = 0; // ensure NULL
		len_required = strlen(s_ptr->name) + 1 + strlen(val_string) + add_char;
		if (len_required < VAR_WIDTH)
			inc = 1;
		else if (len_required < 2 * VAR_WIDTH)
			inc = 2;
		else
			inc = vp.vars_per_line; /* use whole line, possibly run off the end */
	}

	/* is var already on display ? */
	already_there = FALSE;
	for (i = 0; i < vp.display_size; i += inc) {
		if (display_list[i].sym == s_ptr) { 
			found = i;
			already_there = TRUE;
			break;
		}
	}

	if (already_there) {
		screen_val = display_list[found].value_on_screen;
		if (IS_ATOM_INT_NV(screen_val) && screen_val == val) {
			return; /* correct integer or NOVALUE value is already there */
		}
		else {
			if (IS_ATOM(val)) {
				if (found < vp.display_size-1 && 
					display_list[found+1].sym == s_ptr) {
					// we might be downsizing this var in-place
					EraseSymbol(s_ptr);
				}
			}
		}
	}
	else {
		/* not there - look for the best slot (oldest time stamp) */
		found = 0;
		for (i = inc; i < vp.display_size; i += inc) {
			if (display_list[i].time_stamp < display_list[found].time_stamp) {
				found = i;
			}
		}
		if (display_list[found].sym != NULL)
			EraseSymbol(display_list[found].sym); // clear existing var
		EraseSymbol(s_ptr); /* in case it is somewhere else (unaligned) */
	}
	
	for (i = found; i < found + inc; i++) {
		display_list[i].sym = s_ptr;
		display_list[i].time_stamp = tstamp;
	}
	tstamp++;

	set_text_color(15); 
	buffer_screen();
	if (already_there && display_list[found].value_on_screen != (NOVALUE-1)) {
		// skip printing the name and '=' sign
		// Note: sometimes vars are cleared, but we want them to be
		// reprinted in the same positions to avoid confusing the user.
		// In that case already_there will be true but value will be NOVALUE-1
		SetVarPosition(found, strlen(s_ptr->name)+1);
	}
	else {
		SetVarPosition(found, 0);
		snprintf(TempBuff, TEMP_SIZE, "%s=", s_ptr->name);
		TempBuff[TEMP_SIZE-1] = 0; // ensure NULL
		screen_output(NULL, TempBuff);
	}
	display_list[found].value_on_screen = val; 
	
	if (IS_SEQUENCE(val)) {
		Print(NULL, val, 1, (vp.vars_per_line * VAR_WIDTH) - 3, 
			  strlen(s_ptr->name)+1, FALSE);
		screen_blank(NULL, vp.columns);
		if (user_requested && print_chars == -1) {
			// not enough room to show whole sequence
			flush_screen();
			col = screen_col;
#ifdef EWINDOWS         
			SaveTrace();
#else
#ifdef EUNIX
			screen_copy(screen_image, alt_image_debug);
			blank_lines(0, vp.lines - 1);
#else
			SaveDebugImage();  // should work for DOS, 
							   // Linux will need a new window like Windows
#endif
#endif          
			ClearScreen();
			set_text_color(15);  // Al Getz bug
			snprintf(TempBuff, TEMP_SIZE, "%s=", s_ptr->name);
			TempBuff[TEMP_SIZE-1] = 0; // ensure NULL
			screen_output(NULL, TempBuff);
			Print(NULL, val, vp.lines - 5, (vp.vars_per_line * VAR_WIDTH) - 3, 
				  strlen(s_ptr->name), TRUE);
			screen_output(NULL, "\n\n* Press Enter to resume trace\n");
			if (print_chars != -1)
				get_key(TRUE); // wait for Enter key
#ifdef EWINDOWS         
			RestoreTrace();
#else
#ifdef EUNIX
			screen_copy(alt_image_debug, screen_image);
			screen_show();
#else           
			RestoreDebugImage();
#endif
#endif          
			screen_col = col;
		}
	}
	else {  
		// ATOMS and NOVALUE
		screen_output(NULL, val_string);
		if (add_char) 
			show_ascii_char(NULL, iv);
		
		screen_blank(NULL, inc*VAR_WIDTH - len_required);
	}
	flush_screen();
}

void UpdateGlobals()
/* update variables on the debug screen */
{
	symtab_ptr dsym, proc, sym;
	int i;
	struct EuViewPort vp;
	
	GetViewPort( &vp );
	
	if (TEXT_MODE)
		set_bk_color(_BLUE);
	proc = Locate(tpc);
	if (proc == NULL)
		LocateFail();
	sym = proc->next;
	for (i = 0; i < vp.display_size; i++) {
		dsym = display_list[i].sym;
		if (dsym == NULL) {
			/* fill empty slot with a private. not really optimal but ok */
			if (sym && (sym->scope == S_PRIVATE && sym->obj != NOVALUE)) {
				DisplayVar(sym, FALSE);
				sym = sym->next;
			}       
		}
		else if (dsym->scope > S_PRIVATE && !PrivateName(dsym->name, proc)
				 || ValidPrivate(dsym, proc)) {
			/* skip redundant slots */
			do {
				i++;
			} while (i < vp.display_size && display_list[i].sym == dsym);
			i--;
			/* display up-to-date value */
			DisplayVar(dsym, FALSE);
		}
		else
			EraseSymbol(dsym);
	}
}

void ShowDebug()
/* switch to debug screen from main screen */
{
	int i;
	long size;
	struct EuViewPort vp;

	if (current_screen == DEBUG_SCREEN)
		return;
	
	GetViewPort( &vp );
	
	main_screen_col = screen_col;
	main_screen_line = screen_line;
	screen_col = debug_screen_col;
	screen_line = debug_screen_line;
	MainWrap = wrap_around;
#ifdef EWINDOWS
	SaveNormal();
	RestoreTrace();
#endif

#ifdef EUNIX
	MainCol = current_fg_color;
	MainBkCol = current_bg_color;
	screen_copy(screen_image, alt_image_main);
	screen_copy(alt_image_debug, screen_image);
	screen_show();
#endif

	Wrap(ATOM_0);

	if (first_debug) {
		for (i = 0; i < vp.display_size; i++) 
			ClearSlot(i);
		init_class();
#ifndef EUNIX
		conin = iopen("CON", "r");
		if (conin == NULL)
#endif
			conin = stdin;
	}
	current_screen = DEBUG_SCREEN;
	Refresh(start_line, TRUE); 
	first_debug = FALSE;
}

static void SaveDebugImage()
/* save image of debug screen (if there's enough memory) */
{
#ifdef EWINDOWS
	DebugScreenSave = (char *)1;
#endif
}

static void RestoreDebugImage()
/* redisplay debug screen image */
{
#ifdef EWINDOWS
	SaveNormal();
	RestoreTrace();
#endif
	screen_col = debug_screen_col;
	Wrap(0);
	current_screen = DEBUG_SCREEN;
	DebugScreenSave = NULL;
}

static void DebugCommand()
/* process user debug command */
{
	int c;

	while (TRUE) {
		c = get_key(TRUE);
#ifdef EUNIX
		// must handle ANSI codes
		if (c == 27) {
			c = get_key();
			if (c == 91) {
				c = get_key();
				if (c == 66) {
					c = DOWN_ARROW;
				}
				else if (c == 49) {
					c = get_key();
					if (c == 49) {
						c = FLIP_TO_MAIN;
						get_key();  // 126
					}
					else if (c == 50) {
						c = FLIP_TO_DEBUG;
						get_key(); // 126
					}
				}
			}
		}
#endif
		if (c == FLIP_TO_MAIN) {
			SaveDebugImage();
			MainScreen(); /* we will be in DEBUG_SCREEN here */
			while ((c = get_key(TRUE)) == FLIP_TO_MAIN)
				;
			if (DebugScreenSave != NULL)
				RestoreDebugImage();
			else
				ShowDebug();
		}
		else if (c == 'q') {
			TraceOn = FALSE;
			MainScreen(); /* we will be in DEBUG_SCREEN here */
			break;
		}
		else if (c == 'Q') {
			TraceOn = FALSE;
			trace_enabled = FALSE;
			MainScreen();
			break;
		}
		else if (c == DOWN_ARROW) {
			TraceOn = FALSE;
			TraceBeyond = start_line;
			TraceStack = expr_top - expr_stack;
			break;
		}
		else if (c == '?') {
			ShowName();
		}
		else if (c == '\r' || c == '\n'
#ifdef EWINDOWS
				 || c == 284
#endif
		
		) {
			break;
		}
		else if (c == '!') {
			RTFatal("program aborted");
			break;
		}
	}
}


void DebugScreen()
/* Display the debug screen, if it is not already there */
{
	/* set up the debug screen */
	if (current_screen == DEBUG_SCREEN)
		ShowTraceLine(start_line);
	else
		ShowDebug();
	DebugCommand();
}


void EraseSymbol(symtab_ptr sym)
/* clear a variable from the display */
{
	int i;
	symtab_ptr dsym;
	int prev;
	struct EuViewPort vp;
	
	GetViewPort( &vp );
	prev = -1;
	if (TEXT_MODE)
		set_bk_color(_BLUE);
	/* clear out any slots with same name */
	for (i = 0; i < vp.display_size; i++) {
		dsym = display_list[i].sym;
		if (dsym != NULL && strcmp(dsym->name, sym->name) == 0) {
			if (i != (prev + 1) || (i % vp.vars_per_line) == 0) {
				// can't build on previous
				flush_screen();
				SetVarPosition(i, 0);
				buffer_screen();
			}
			prev = i;
			screen_blank(NULL, VAR_WIDTH);
			ClearSlot(i);
		}
	}
	if (prev != -1)
		flush_screen();
}

static void ShowName()
/* display a requested variable name & value */
{
	char name[80];
	symtab_ptr name_ptr;
	int prompt, i, j, name_len;
	struct EuViewPort vp;
	
	GetViewPort( &vp );

	set_text_color(0);
	if (TEXT_MODE)
		set_bk_color(_YELLOW);
	prompt = vp.num_trace_lines + BASE_TRACE_LINE + 1;
	SetPosition(prompt, 1);
	buffer_screen();
#ifdef EWINDOWS
	screen_output(NULL, "variable name? _");
#else
	screen_output(NULL, "variable name?");
#endif  
	screen_blank(NULL, vp.columns - 14);
	flush_screen();
	
	SetPosition(prompt, 16); 

	key_gets(name);
	/* ignore leading whitespace */
	i = 0;
	while (name[i] == ' ' || name[i] == '\t')
		i++;    

	/* ignore trailing whitespace */
	j = strlen(name)-1;
	while (name[j] == '\n' || name[j] == ' ' || name[j] == '\t')
		name[j--] = '\0';

	if (i > j) {
		if (TEXT_MODE)
			set_bk_color(_BLUE);
		SetPosition(prompt, 1);
		buffer_screen();
		screen_blank(NULL, vp.columns);
		flush_screen();
		return;
	}

	name_len = strlen(name);
	name_ptr = RTLookup(name+i, slist[trace_line].file_no, tpc, NULL, 999999999); 
	if (name_ptr == NULL || name_ptr->token != VARIABLE) {
		SetPosition(prompt, 18 + name_len);
		screen_output(NULL, "- not defined at this point");
	}
	else
		DisplayVar(name_ptr, TRUE);
}

#endif // not BACKEND

static void ListTraceLine(int gline)
/* write traced line out to ex.err */
{
	char *name;
	struct sline *line_info;
	
	if (gline == 0)
		return;
	line_info = &slist[gline];
	name = file_name[line_info->file_no];
	iprintf(TempErrFile, "%s:%u\t%s\n", 
			name, 
			line_info->line, 
			line_info->src + 4 * 
			 ((line_info->options & OP_PROFILE_STATEMENT) || 
			  (line_info->options & OP_PROFILE_TIME)));
}

static void RecentLines()
/* display the lines executed recently */
{
	int i;

	if (traced_lines) {
		iprintf(TempErrFile, "\nTraced lines leading up to the failure:\n\n");
		for (i = TraceLineNext; i < TraceLineSize; i++)
			ListTraceLine(TraceLineBuff[i]);
		for (i = 0; i < TraceLineNext; i++)
			ListTraceLine(TraceLineBuff[i]);
		iprintf(TempErrFile, "\n");
	}
}

static void DumpPrivates(IFILE f, symtab_ptr proc)
/* display the local variables and their values for a subprogram */
{
	symtab_ptr sym;

	/* iprintf(f, " %s()\n", proc->name);*/
	sym = proc->next; 
	while (sym != NULL && 
		   (sym->scope == S_PRIVATE || sym->scope == S_LOOP_VAR || sym->scope == S_UNDEFINED)) {
		if (sym->scope != S_UNDEFINED ){
			if (sym->obj == NOVALUE) {
				iprintf(f, "    %s = <no value>\n", sym->name);
			}
			else {
				iprintf(f, "    %s = ", sym->name);
				Print(f, sym->obj, 500, 80 - 3, strlen(sym->name)+6, TRUE);
				iprintf(f, "\n");
			}
		}
		sym = sym->next;
	}
}

static void DumpGlobals(IFILE f)
/* display the global and local variable values */
{
	symtab_ptr sym;
	int prev_file_no;

	prev_file_no = -1;
	sym = TopLevelSub->next;
	iprintf(f, "\n\nGlobal & Local Variables\n");
	while (sym != NULL) {
		if (sym->token == VARIABLE && 
			sym->mode == M_NORMAL &&
			(sym->scope == S_LOCAL || sym->scope == S_GLOBAL ||
			 sym->scope == S_GLOOP_VAR)) {
			if (sym->file_no != prev_file_no) {
				prev_file_no = sym->file_no;
				iprintf(f, "\n %s:\n", file_name[prev_file_no]);
			}
			iprintf(f, "    %s = ", sym->name);
			if (sym->obj == NOVALUE)
				iprintf(f, "<no value>");
			else 
				Print(f, sym->obj, 500, 80 - 3, strlen(sym->name)+6, TRUE);
			iprintf(f, "\n");
		}
		sym = sym->next;
	}
	iprintf(f, "\n");
}

static int screen_err_out;

#define TPTEMP_BUFF_SIZE (800)
static char TPTempBuff[TPTEMP_BUFF_SIZE]; // TempBuff might contain the error message

static sf_output(char *string)
// output error info to ex.err and optionally to the screen
{
	iprintf(TempErrFile, "%s", string);
	if (screen_err_out) {
		screen_output(stderr, string);
	}
}

static void TracePrint(symtab_ptr proc, int *pc)
// print a line of traceback
{
	long gline;
	unsigned int line, file;
	char *subtype;

	gline = FindLine(pc, proc);
	if (gline == 0) {
		LocateFail();
	}
	line = slist[gline].line;
	file = slist[gline].file_no;

	if (proc->token == PROC)
		subtype = "procedure";
	else if (proc->token == FUNC)
		subtype = "function";
	else
		subtype = "type";

	if (proc == TopLevelSub) {
		snprintf(TPTempBuff, TPTEMP_BUFF_SIZE, "%s:%u", file_name[file], line);
		TPTempBuff[TPTEMP_BUFF_SIZE-1] = 0; // ensure NULL
		sf_output(TPTempBuff);
	}
	else {
		snprintf(TPTempBuff, TPTEMP_BUFF_SIZE, "%s:%u in %s %s() ",
				 file_name[file], line, subtype, proc->name);
		TPTempBuff[TPTEMP_BUFF_SIZE-1] = 0; // ensure NULL
		sf_output(TPTempBuff);
	}
}

static void TraceBack(char *msg, symtab_ptr s_ptr)
// stack traceback when an error occurs
// Note: msg must be read in this routine, before TempBuff is written
// msg is error message or NULL
// s_ptr is symbol involved in error
{
	int *new_pc;
	symtab_ptr current_proc, prev_proc, sym;
	object_ptr obj_ptr;
	int levels, skipping, dash_count, i, task, show_message;
	char *routine_name;
	
	buffer_screen();
	
	if (crash_msg == NULL) {
		screen_err_out = TRUE;  
		screen_output(stderr, "\n");
	}
	else {
		screen_err_out = FALSE;
	}
		
	show_message = TRUE;
	
	while (TRUE) {
		// do full traceback for the next task
		
		if (tcb_size > 1) {
			// multiple tasks were used - label them
			if (current_task == 0) {
				routine_name = "initial task";
			}
			else {
				routine_name = e_routine[tcb[current_task].rid]->name;
			}
			snprintf(TPTempBuff, TPTEMP_BUFF_SIZE, " TASK ID %.0f %s ",
					 tcb[current_task].tid, routine_name);
			TPTempBuff[TPTEMP_BUFF_SIZE-1] = 0; // ensure NULL
			dash_count = 60;
			if (strlen(TPTempBuff) < dash_count) {
				dash_count = 52 - strlen(TPTempBuff);
			}
			if (dash_count < 1) {
				dash_count = 1;
			}
			sf_output("----------------------");
			sf_output(TPTempBuff);
			for (i = 1; i <= dash_count; i++) {
				sf_output("-");
			}
			sf_output("\n");
		}
		
		current_proc = Locate(tpc);
		if (current_proc == NULL) {
			LocateFail();
		}
		TracePrint(current_proc, tpc);
		
		if (show_message) {
			// display the error message
			show_message = FALSE;
			if (s_ptr == NULL) {
				snprintf(TPTempBuff, TPTEMP_BUFF_SIZE, "\n%s", msg);
				TPTempBuff[TPTEMP_BUFF_SIZE-1] = 0; // ensure NULL
				sf_output(TPTempBuff);
			}
			else {
				sf_output(type_error_msg); // test
				snprintf(TPTempBuff, TPTEMP_BUFF_SIZE, "%s is ", s_ptr->name);
				TPTempBuff[TPTEMP_BUFF_SIZE-1] = 0;
				sf_output(TPTempBuff);
				if (screen_err_out)
					Print(stderr,  s_ptr->obj, 1, 50, 0, FALSE);
				Print(TempErrFile, s_ptr->obj, 1, 50, 0, FALSE);
			}
		}
		sf_output(" \n");
		
		iflush(TempErrFile); // in case we crash later
		
		DumpPrivates(TempErrFile, current_proc);
	
		iflush(TempErrFile); // in case we crash later
			
		levels = 0;
		skipping = 0;
		
		while (expr_top > expr_stack+3) {
			// unwind the stack for this task
			
			expr_top -= 2;
			new_pc = (int *)*expr_top;
			
			if (current_proc->u.subp.saved_privates != NULL) {
				// called recursively or multiple tasks - restore privates
				current_proc->u.subp.resident_task = -1;
				restore_privates(current_proc);
			}
			
			if (*new_pc == (int)opcode(CALL_BACK_RETURN)) {
				// we're in a callback routine
				if (crash_count > 0) {
					copy_string(TempBuff, "\n^^^ called to handle run-time crash\n", TEMP_SIZE);
				}
				else {
#ifdef EWINDOWS         
					copy_string(TempBuff, "\n^^^ call-back from Windows\n", TEMP_SIZE);
#else           
					copy_string(TempBuff, "\n^^^ call-back from external source\n", TEMP_SIZE);
#endif          
				}
				sf_output(TempBuff);
				if (expr_top <= expr_stack+3)
					break;
				expr_top -= 2;
				new_pc = (int *)*expr_top;
			}

			current_proc = Locate(new_pc - 1);
			if (current_proc == NULL) {
				LocateFail();
			}
			if (levels < MAX_TRACEBACK) {
				sf_output("\n... called from ");
				TracePrint(current_proc, new_pc - 1); 
				sf_output(" \n");
				DumpPrivates(TempErrFile, current_proc);        
				levels++;
			}
			else {
				skipping++;
			}
		} // end while
		
		if (skipping > 0) {
			snprintf(TempBuff, TEMP_SIZE, "\n... (skipping %d levels)\n\n", skipping);
			TempBuff[TEMP_SIZE-1] = 0; // ensure NULL
			sf_output(TempBuff);
		}   
	
		iflush(TempErrFile); // in case we crash later
	
		tcb[current_task].status = ST_DEAD;  // mark as "deleted"
		
		// choose next task to display
		task = current_task;
		for (i = 0; i < tcb_size; i++) {
			if (tcb[i].status != ST_DEAD && 
				tcb[i].impl.interpreted.expr_top > tcb[i].impl.interpreted.expr_stack+2-(tcb[i].tid == 0.0)) {
				current_task = i;
				expr_stack = tcb[i].impl.interpreted.expr_stack;
				expr_top = tcb[i].impl.interpreted.expr_top;
				tpc = tcb[i].impl.interpreted.pc;
				screen_err_out = FALSE; // only show offending task on screen
				break;
			}
		} 
		if (task == current_task) {
			break;  // no more non-killed tasks
		}  
		sf_output("\n");
	} // end while
	
	DumpGlobals(TempErrFile);
	
	iflush(TempErrFile); // in case we crash later
	
	RecentLines();
}

#ifdef EXTRA_CHECK
void RTInternal(char *msg, ...)
{
	va_list ap;
	va_start(ap, msg);
	RTInternal_va(msg, ap);
	va_end(ap);
}

void RTInternal_va(char *msg, va_list ap)
/* handles run-time internal errors 
   - see InternalErr() for compile-time errors */
{
#define RTI_bufflen (1000)
	char *msgtext;
	char *buf;
	
    msgtext = (char *)EMalloc(RTI_bufflen);
	if (msgtext) {
	    buf = msgtext;
		vsnprintf(msgtext, RTI_bufflen, msg, ap);
		msgtext[RTI_bufflen - 1] = 0;
	} else {
		msgtext = "RTI memory allocation failed\n";
		buf = 0;
	}
	gameover = TRUE;

	debug_msg(msgtext);
	
	OpenErrFile();  // exits if error file name is ""

	TraceBack(msgtext, NULL);
	
	iflush(TempErrFile);

	if (buf) EFree(msgtext);
	Cleanup(1);
}
#endif

#define CUE_bufflen (200)
void CleanUpError_va(char *msg, symtab_ptr s_ptr, va_list ap)
{
	long i;

	char *msgtext;
	char *buf;
	
	if (msg) {
	    msgtext = (char *)EMalloc(CUE_bufflen);
		if (msgtext) {
		    buf = msgtext;
			i = vsnprintf(msgtext, CUE_bufflen - 1, msg, ap);
			if (i < 0 ) {
				i = CUE_bufflen - 1;
			}
			msgtext[i] = 0;
		}
		else {
			msgtext = "CleanUpError memory allocation failed\n";
			buf = 0;
		}
	}
	else {
		msgtext = 0;	// Special for type check messaging.
		buf = 0;
	}

	if (crash_msg != NULL) {
		ClearScreen();
		screen_output(stderr, crash_msg);
	}
	OpenErrFile();
	TraceBack(msgtext, s_ptr);
	
	iprintf(TempErrFile, "\n");
	
	// store all warnings at end of ex.err
	for (i = 0; i < warning_count; i++)
		iprintf(TempErrFile, "%s", warning_list[i]);
	
	iclose(TempErrFile);
	
	if (crash_msg == NULL) {
		screen_output(stderr, "\n--> See ");
		screen_output(stderr, TempErrName);
		screen_output(stderr, " \n");
	}
	
	call_crash_routines();  
	
	gameover = TRUE;

	if (buf) EFree(msgtext);
	Cleanup(1);
}

void CleanUpError(char *msg, symtab_ptr s_ptr, ...)
{
	va_list ap;
	va_start(ap, s_ptr);
	CleanUpError_va(msg, s_ptr, ap);
	va_end(ap);
}

void RTFatalType(int *pc)
/* handle type-check failures */
/* pc points to variable in instruction stream */ 
{
	symtab_ptr s_ptr;

	tpc = pc; /* points within the offending assignment/parm setting */
	s_ptr = *(symtab_ptr *)pc;
	CleanUpError(NULL, s_ptr);
}

object_ptr BiggerStack()
/* enlarge the runtime call stack */
{
	int top;

	top = expr_top - expr_stack;
	stack_size = stack_size + stack_size + max_stack_per_call;
	expr_stack = (object_ptr)ERealloc((char *)expr_stack, stack_size * sizeof(object));
	expr_top = expr_stack + top;
	return expr_stack + stack_size - 5; /* new expr_max */
}

void BadSubscript(object subs, long length)
/* report a subscript violation */
{
#define BadSubscript_bufflen (40)
	char subs_buff[BadSubscript_bufflen];
	
	if (IS_ATOM_INT(subs))
		snprintf(subs_buff, BadSubscript_bufflen, "%d", subs);
	else
		snprintf(subs_buff, BadSubscript_bufflen, "%.10g", DBL_PTR(subs)->dbl);
	subs_buff[BadSubscript_bufflen - 1] = 0; // ensure NULL

	RTFatal("subscript value %s is out of bounds, assigning to a sequence of length %ld",
			subs_buff, length);
}

void SubsAtomAss()
{
	RTFatal("attempt to subscript an atom\n(assigning to it)");
}

void SubsNotAtom()    
{
	RTFatal("subscript must be an atom\n(assigning to subscript of a sequence)");
}

void RangeReading(object subs, int len)
{
#define RangeReading_buflen (40)
	char subs_buff[RangeReading_buflen];
	
	if (IS_ATOM_INT(subs))
		snprintf(subs_buff, RangeReading_buflen, "%d", subs);
	else
		snprintf(subs_buff, RangeReading_buflen, "%.10g", DBL_PTR(subs)->dbl);
	subs_buff[RangeReading_buflen - 1] = 0; // ensure NULL
	
	RTFatal("subscript value %s is out of bounds, reading from a sequence of length %ld",
			subs_buff, len);
}

void NoValue(symtab_ptr s)
{
	RTFatal("variable %s has not been assigned a value", s->name);
}

void atom_condition()
{
	RTFatal("true/false condition must be an ATOM");
}

/* signal handlers */

#ifdef EWINDOWS
extern void DisableControlCHandling(); // be_w.c
#endif

void INT_Handler(int sig_no)
/* control-c, control-break */
{
	if (!allow_break) {
		signal(SIGINT, INT_Handler);
		control_c_count++;
		return;
	}
	gameover = TRUE;
#ifdef EWINDOWS
	DisableControlCHandling();
#endif
	Cleanup(1); 
	/* just do this - else DOS extender bug */
				 /* seems to crash in Windows */
	/* RTFatal("program interrupted");*/
}

#if (  defined(__DJGPP__) && ( (__DJGPP__ == 2 && __DJGPP_MINOR__ < 4)  ||  (__DJGPP__ < 2) )  )
/* __DJGPP__ library version earlier than 2.4.  Use unsafe alternatives. */
unsigned int snprintf(char * buf, size_t size, char * fmt, ...) {
	unsigned int r;
	va_list ap;
	va_start(ap, fmt);
	r = vsnprintf(buf,size,fmt,ap);
	va_end(ap);
	return r;
}
signed int vsnprintf(char * buf, size_t size, char * fmt, va_list list ) {
	return vsprintf(buf,fmt,list);	
}
#endif

extern int line_max;
extern int col_max;

void GetViewPort(struct EuViewPort *vp)
{
	int l_var_lines;
#ifdef EUNIX
	struct winsize ws;
#endif

#ifdef EWINDOWS
	CONSOLE_SCREEN_BUFFER_INFO info;
	
	GetConsoleScreenBufferInfo(console_output, &info);
	
	vp->lines    = info.dwSize.Y;
	vp->columns  = info.dwSize.X;

#endif

#ifdef EUNIX
	if (consize_ioctl != 0 && !ioctl(STDIN_FILENO, TIOCGWINSZ, &ws)) {
		line_max = ws.ws_row;
		col_max = ws.ws_col;
		if (line_max > MAX_LINES)
			line_max = MAX_LINES;
		if (col_max > MAX_COLS)
			col_max = MAX_COLS;
	}
	vp->lines    = line_max;
	vp->columns  = col_max;

#endif
	l_var_lines = (vp->lines - BASE_TRACE_LINE) / 6;
	if (l_var_lines > MAX_VAR_LINES)
		l_var_lines = MAX_VAR_LINES;
	vp->vars_per_line = vp->columns / VAR_WIDTH;
	if (vp->vars_per_line > MAX_VARS_PER_LINE)
		vp->vars_per_line = MAX_VARS_PER_LINE;
	vp->display_size = l_var_lines * vp->vars_per_line;
	vp->num_trace_lines = vp->lines - l_var_lines - BASE_TRACE_LINE - NUM_PROMPT_LINES;
}
