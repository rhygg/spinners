#include "spinner.h"

#include <windows.h>

#include <stdlib.h>

#include <stdio.h>

// console handle
static HANDLE con = NULL;

// default color attributes
static WORD default_attributes = 0;

// windows uses this instead of ansi escape chars :sob:
static
const WORD colors[8] = {
    0, // black
    FOREGROUND_RED, // red
    FOREGROUND_GREEN, // green
    FOREGROUND_RED | FOREGROUND_GREEN, // yellow
    FOREGROUND_BLUE, // blue
    FOREGROUND_RED | FOREGROUND_BLUE, // magenta
    FOREGROUND_GREEN | FOREGROUND_BLUE, // cyan
    FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE // white
};

static void init_handle(void) {
    con = GetStdHandle(-11);

    CONSOLE_SCREEN_BUFFER_INFO csbi;
    GetConsoleScreenBufferInfo(con, & csbi);

    default_attributes = csbi.wAttributes;
}

// function called by success(), error(), warn(), and info()
// after the thread was stopped
void print_post_exit(int prev_len,
    const int color,
        const int symbol_char_code,
            const char * message,
                const int message_len) {

    if (con == NULL)
        init_handle();

    WriteConsoleA(con, "\r ", 2, NULL, NULL);

    SetConsoleTextAttribute(con, colors[color - 48]);
    WriteConsoleW(con, & symbol_char_code, 1, NULL, NULL);

    SetConsoleTextAttribute(con, default_attributes);
    printf(" %s", message);

    while (message_len < prev_len) {
        putchar(32);
        prev_len--;
    }

    putchar('\n');
}

// function called every time the library is about to print a frame
void print_spinner_text(
    const int color,
        const char * frame,
            const char * new_text,
                const int new_text_size, int prev_len) {

    if (con == NULL)
        init_handle();

    WriteConsoleA(con, "\r ", 2, NULL, NULL);

    SetConsoleTextAttribute(con, colors[color - 48]);
    printf("%s ", frame);

    SetConsoleTextAttribute(con, default_attributes);
    WriteConsole(con, new_text, new_text_size, NULL, NULL);

    // this may seem tedious but it fixes a stdout glitch
    while (new_text_size < prev_len) {
        putchar(32);
        prev_len--;
    }
}