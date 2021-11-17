module spinners

import os { read_file, dir, real_path, join_path }
import x.json2 { raw_decode }
import time

struct Spinner {
    name string
    frames []string // frames of the spinner
    interval i64 // in milliseconds
}

fn get_from_json(posx string) ?Spinner {
    spinners_data := read_file(real_path(join_path(dir(@FILE), "./spinners_condensed.json"))) ?
    mp_obj := raw_decode(spinners_data) ?    
    arr := mp_obj.arr().map(it.as_map())
    
    for mp in arr {
        name := mp['name'] ?
    
        if name.str() == posx {
            f := mp['frames'] ?
            i := mp['interval'] ?
        
            return Spinner {
                frames: f.arr().map(it.str())
                interval: i.int() * time.millisecond
            }
        }
    }
    
    return error("Couldn't find the specified spinner")
}

fn print_spinner(spin &Spinner, prefix string) {
    for frame in spin.frames {
        print(' \r $frame $prefix')

        time.sleep(spin.interval)
    }
}

pub fn spin(_posx string, prefix string) ? {
    data := get_from_json(_posx) ?
    print_spinner(data, prefix)
}