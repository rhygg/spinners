module spinners

import os { read_file }
import json { decode }
import time { sleep, millisecond }

struct Spinner {
     name string  // name of the spinner
     frames []string // frames of the spinner
     interval int // in milliseconds
}

pub fn get_frames(_posx string) ?[]string {
    spinners_data := read_file(os.real_path(os.join_path(os.dir(@FILE), "./spinners.json"))) ?
  
    mut sets := decode([]Spinner, spinners_data) ?

    for mut set in sets {
        if set.name == _posx && set.frames != [] {
            return set.frames
        }
    }

    return error("Couldn't find the specified spinner")
}

pub fn get_interval(_posx string) ?int {
    spinners_data := os.read_file(os.real_path(os.join_path(os.dir(@FILE), "./spinners.json"))) ?

    mut sets := decode([]Spinner, spinners_data) ?
    for mut set in sets {
        if set.name == _posx {
            return set.interval
        }
    }

    return 0
}

pub fn print_spinner(prefix string, frames []string, interval int) ? {
    for frame in frames {
        print(' \r $frame $prefix')

        sleep(interval * millisecond)
    }
}

pub fn spin(_posx string, prefix string) ? {
    frames := get_frames(_posx) ?
    interval := get_interval(_posx) ?
      
    h := go print_spinner(prefix, frames, interval)

    h.wait() ?
}
