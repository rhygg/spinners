#include "spinner.h"
#include <stdio.h>

#ifdef _WIN32

#ifdef UNICODE
#undef UNICODE
#endif

#include <windows.h>
#include <stdlib.h>

// console handle
static HANDLE con = NULL;

// default color attributes
static WORD default_attributes = 0;

// windows uses this instead of ansi escape chars :sob:
static const WORD colors[8] = {
    0,                                                  // black
    FOREGROUND_RED,                                     // red
    FOREGROUND_GREEN,                                   // green
    FOREGROUND_RED | FOREGROUND_GREEN,                  // yellow
    FOREGROUND_BLUE,                                    // blue
    FOREGROUND_RED | FOREGROUND_BLUE,                   // magenta
    FOREGROUND_GREEN | FOREGROUND_BLUE,                 // cyan
    FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE // white
};

static void init_handle(void) {
    if (con == NULL) {
        con = GetStdHandle(-11);
    
        CONSOLE_SCREEN_BUFFER_INFO csbi;
        GetConsoleScreenBufferInfo(con, &csbi);
        
        default_attributes = csbi.wAttributes;
    }
}
#endif

/* todo. ignore
// function called by success(), error(), warn(), and info()
// after the thread was stopped
void print_post_exit(const int previous_text_len, const int previous_frame_len, const int color,
    const int symbol_char_code, const char * message) {
#ifdef _WIN32
    init_handle();
#endif

    fputs("\r ", stdout);
    
#ifndef _WIN32
    printf("\x1b[3%cm");
}*/

// function called every time the library is about to print a frame
void print_spinner_text(
    const int color, const char * frame, const char * new_text,
    const int new_text_size, const int prev_len) {
#ifdef _WIN32
    init_handle();
#endif

    fputs("\r ", stdout);
    
#ifndef _WIN32
    printf("\x1b[3%cm%s\x1b[0m %s", color, frame, new_text);
#else
    SetConsoleTextAttribute(con, colors[color - 48]);
    fputs(frame, stdout);
    
    // putchar(32) writes a single space character to stdout
    putchar(32);
    
    SetConsoleTextAttribute(con, default_attributes);
    WriteConsole(con, new_text, new_text_size, NULL, NULL);
#endif

    // this may seem tedious but it fixes a stdout bug
    if (new_text_size < prev_len) {
        while (prev_len > new_text_size) {
            putchar(32);
            prev_len--;
        }
    }
}