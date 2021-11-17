module spinners

import os { read_file, dir, real_path, join_path }
import x.json2 { raw_decode }
import time

// shared objects must be a struct, map, or array
struct SharedSpinner {
mut:
    is_running bool
}

pub struct Spinner {
mut:
    shr shared SharedSpinner
    running_thread thread
}

fn get_from_json(posx string) ?([]string, i64) {
    spinners_data := read_file(real_path(join_path(dir(@FILE), "./spinners_condensed.json"))) ?
    mp_obj := raw_decode(spinners_data) ?    
    arr := mp_obj.arr().map(it.as_map())
    
    for mp in arr {
        name := mp['name'] ?
    
        if name.str() == posx {
            f := mp['frames'] ?
            i := mp['interval'] ?
        
            return f.arr().map(it.str()), i.int() * time.millisecond
        }
    }
    
    return error("Couldn't find the specified spinner")
}

fn (mut self Spinner) spinner_thread(frames []string, interval i64, suffix string) {
    mut index := 0
    
    for {
        frame := frames[index]
        print(' \r $frame $suffix')
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

pub fn (mut self Spinner) start(_posx string, suffix string) ? {
    lock self.shr {
        if self.shr.is_running == true {
            return error("Spinner is already running.")
        }
        
        self.shr.is_running = true
        
        frames, interval := get_from_json(_posx) ?
        self.running_thread = go self.spinner_thread(frames, interval, suffix)
    }
}

pub fn (mut self Spinner) stop() ? {
    lock self.shr {
        if self.shr.is_running == false {
            return error("Spinner is not running.")
        }
        
        self.shr.is_running = false
    }
    
    self.running_thread.wait()
}

// TODO: add success method
// pub fn success(suffix string) ? {
// 
// }
