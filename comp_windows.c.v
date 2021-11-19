module spinners

#flag -I @VMODROOT
#flag @VMODROOT/spinner.o
#include "spinner.h"

// windows functions
fn C.print_spinner_text(int, &char, &char, int, int)
fn C.print_post_exit(int, int, int, &char, int)