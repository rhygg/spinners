module spinners

// @description A collection of spinners accessible to the terminal
// @author      Adonis Tremblay
// @license     MIT

import os { dir, join_path, read_file, real_path }
import x.json2 { raw_decode }
import time

#flag -I @VMODROOT
#flag @VMODROOT/spinner.o
#include "spinner.h"

fn C.print_spinner_text(u8, &char, &char, int, int)

// animation types
pub enum AnimationType {
    @none
    dots
    dots2
    dots3
    dots4
    dots5
    dots6
    dots7
    dots8
    dots9
    dots10
    dots11
    dots12
    dots8_bit
    line
    line2
    pipe
    simple_dots
    simple_dots_scrolling
    star
    star2
    flip
    hamburger
    grow_vertical
    grow_horizontal
    balloon
    balloon2
    noise
    bounce
    box_bounce
    box_bounce2
    triangle
    arc
    circle
    square_corners
    circle_quarters
    circle_halves
    squish
    toggle
    toggle2
    toggle3
    toggle4
    toggle5
    toggle6
    toggle7
    toggle8
    toggle9
    toggle10
    toggle11
    toggle12
    toggle13
    arrow
    arrow2
    arrow3
    bouncing_bar
}

// shared objects must be a struct, map, or array
struct SharedSpinner {
mut:
    is_running     bool
    previous_text  string
    text           string
    color          int
}

// colors!!!
pub enum Color {
    white = 55
    red = 49
    green = 50
    yellow = 51
    blue = 52
    magenta = 53
    cyan = 54
    black = 48
}

pub struct Spinner {
mut:
    shr            shared SharedSpinner
    running_thread thread
pub:
    animation      AnimationType
    color          Color
pub mut:
    frames         []string
    interval       i64
}

// constants
const (
    json_path     = real_path(join_path(dir(@FILE), './spinners_condensed.json'))
    default_index = int(AnimationType.line) - 1
)

// set_animation set the animation frames for the given animation type
// `index` is the index of the animation in the animation type
// all panics shouldn't happen, so they are suppressed
fn (mut self Spinner) set_animation(index int) {
    spinners_data := read_file(json_path) or { return }
    mp_obj := raw_decode(spinners_data)   or { return }
    mp := mp_obj.arr()[index].as_map()
    
    f := mp['frames']   or { return }
    i := mp['interval'] or { return }
    
    self.frames   = f.arr().map(it.str())
    self.interval = i.int() * time.millisecond
}

// spinner_thread is the thread that runs the spinner animation
// it is started by the spinner.start() and can be stopped via spinner.stop() method.
// `frames` is the animation frames
// `interval` is the time between frames
fn (mut self Spinner) spinner_thread() {
    mut index := 0

    for {
        lock self.shr {
            C.print_spinner_text(
                self.shr.color, self.frames[index].str, 
                self.shr.text.str, self.shr.text.len,
                self.shr.previous_text.len
            )
            
            if self.shr.text != self.shr.previous_text {
                self.shr.previous_text = self.shr.text
            }
        }

        time.sleep(self.interval)

        rlock self.shr {
            if self.shr.is_running == false {
                return
            }
        }

        index++
        if index == self.frames.len {
            index = 0
        }
    }
}

// start starts the spinner animation
// `text` is the text to display while the spinner is running
pub fn (mut self Spinner) start(text string) ? {
    lock self.shr {
        if self.shr.is_running == true {
            return
        }

        self.shr.is_running = true
        self.shr.text = text
        self.shr.color = int(self.color)
    }

    if self.animation == AnimationType.@none && self.frames.len != 0 && self.interval > 0 {
        self.interval *= time.millisecond
        for frame in self.frames {
            if frame.len != self.frames[0].len {
                return error('every frame must have the same length')
            }
        }
    } else {
        if self.animation == AnimationType.@none {
            self.set_animation(default_index)
        } else {
            self.set_animation(int(self.animation) - 1)
        }
    }
    
    self.running_thread = go self.spinner_thread()
}

// set_text sets the text to display while the spinner is running
// `new_text` is the new text to display
pub fn (mut self Spinner) set_text(new_text string) {
    lock self.shr {
        self.shr.previous_text = self.shr.text
        self.shr.text = new_text
    }
}

// set_color sets the color to use while the spinner is running
// `color` is the color enum
pub fn (mut self Spinner) set_color(color Color) {
    lock self.shr {
        self.shr.color = int(color)
    }
}

// stops the running thread, IF it's running.
fn (mut self Spinner) stop_thread() {
    lock self.shr {
        if self.shr.is_running == false {
            return
        }

        self.shr.is_running = false
    }

    self.running_thread.wait()
}

// stop stops the spinner animation
// it is called automatically when the spinner is dropped
pub fn (mut self Spinner) stop() {
    self.stop_thread()
    print('\n')
}

// success prints a success message
// `text` is the text to display
pub fn (mut self Spinner) success(text string) ? {
    self.stop()
    print('\u001b[32m✔\u001b[0m $text')
}

// error prints an error message
// `text` is the text to display
pub fn (mut self Spinner) error(text string) ? {
    self.stop()
    print('\u001b[31m✘\u001b[0m $text')
}

// warn prints a warning message
// `text` is the text to display
pub fn (mut self Spinner) warn(text string) ? {
    self.stop()
    print('\u001b[33m⚠\u001b[0m $text')
}

// info prints an info message
// `text` is the text to display
pub fn (mut self Spinner) info(text string) ? {
    self.stop()
    print('\u001b[34mℹ\u001b[0m $text')
}