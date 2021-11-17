module spinners

// @description A collection of spinners accessible to the terminal
// @author      Adonis Tremblay
// @license     MIT

import os { dir, join_path, read_file, real_path }
import x.json2 { raw_decode }
import time

const (
        json_path = real_path(join_path(dir(@FILE), './spinners_condensed.json'))
)

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
        is_running bool
        text       string
        color      string
}

pub struct Spinner {
mut:
        shr            shared SharedSpinner
        running_thread thread
pub:
        frames    []string
        interval  i64
        animation AnimationType
}

// get_animation returns the animation frames for the given animation type
// `index` is the index of the animation in the animation type
fn get_animation(index int) ?([]string, i64) {
        spinners_data := read_file(json_path) ?
        mp_obj := raw_decode(spinners_data) ?
        mp := mp_obj.arr()[index].as_map()

        f := mp['frames'] ?
        i := mp['interval'] ?

        return f.arr().map(it.str()), i.int() * time.millisecond
}

// spinner_thread is the thread that runs the spinner animation
// it is started by the spinner.start() and can be stopped via spinner.stop() method.
// `frames` is the animation frames
// `interval` is the time between frames
fn (mut self Spinner) spinner_thread(frames []string, interval &i64) {
        mut index := 0

        for {
                frame := frames[index]

                rlock self.shr {
                        print(' \r $self.shr.color$frame  \u001b[0m $self.shr.text')
                }

                time.sleep(interval)

                rlock self.shr {
                        if self.shr.is_running == false {
                                print('\n') // print newline before exiting
                                return
                        }
                }

                index++
                if index == frames.len {
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
        }

        if self.animation == AnimationType.@none && self.frames.len != 0 && self.interval > 0 {
                self.running_thread = go self.spinner_thread(self.frames, self.interval * time.millisecond)
        } else {
                if self.animation == AnimationType.@none {
                        f, i := get_animation(int(AnimationType.line) - 1) ?
                        self.running_thread = go self.spinner_thread(f, i)
                } else {
                        f, i := get_animation(int(self.animation) - 1) ?
                        self.running_thread = go self.spinner_thread(f, i)
                }
        }
}

// set_text sets the text to display while the spinner is running
// `new_text` is the new text to display
pub fn (mut self Spinner) set_text(new_text string) {
        lock self.shr {
                self.shr.text = new_text
        }
}

// match_color returns the ANSI color code for the given color name
// `color` is the color name
fn match_color(color string) ?string {
        mut x := ''

        match color {
                'red' { x = '31m' }
                'green' { x = '32m' }
                'yellow' { x = '33m' }
                'blue' { x = '34m' }
                'magenta' { x = '35m' }
                'cyan' { x = '36m' }
                'white' { x = '37m' }
                'black' { x = '30m' }
                else { x = '37m' }
        }

        return x
}

// set_color sets the color to use while the spinner is running
// `color` is the color name
pub fn (mut self Spinner) set_color(color string) ? {
        lock self.shr {
                mut col := match_color(color) ?
                self.shr.color = '\u001b[$col'
        }
}

// stop stops the spinner animation
// it is called automatically when the spinner is dropped
pub fn (mut self Spinner) stop() {
        lock self.shr {
                if self.shr.is_running == false {
                        return
                }

                self.shr.is_running = false
        }

        self.running_thread.wait()
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
