
module spinners


import os
import json
import time

struct Spinner {
        name string  // name of the spinner
        frames []string // frames of the spinner
        interval int // in milliseconds
}

pub fn get_frames(_posx string) ?[]string {

spinners_data := os.read_file(os.real_path(os.join_path(os.dir(@FILE), "./spinners.json"))) ?

 mut sets := json.decode([]Spinner, spinners_data) ?

          mut matched := []string{}
           
        for mut set in sets {
                if set.name == _posx {
                        matched = set.frames
                }
        }

        return matched
}

pub fn get_interval(_posx string) ?int {
        spinners_data := os.read_file(os.real_path(os.join_path(os.dir(@FILE), "./spinners.json"))) ?

 mut sets := json.decode([]Spinner, spinners_data) ?

 mut matched := 0

 for mut set in sets {
                if set.name == _posx {
                        matched = set.interval
                }
        }

        return matched
}

pub fn print_spinner(prefix string, frames []string, interval int) ? {
      for frame in frames {

              print(' \r $frame $prefix')

              time.sleep(interval * time.millisecond)
      }
}

pub fn spin(_posx string, prefix string) ? {
        frames := get_frames(_posx) ?

       if frames == [] {
               return error("Couldn't find the specified spinner")
       }

       interval := get_interval(_posx) ?
      
      h := go print_spinner(prefix, frames, interval)

      h.wait() ?
}

