# Spinners in Vlang

### Quick example
```v
import spinners { Spinner }
import time

fn main() {
    mut sp := Spinner{}
    sp.start("please wait...") ?
    
    time.sleep(1000 * time.millisecond)
    
    sp.stop()
    println("done!")
}
```

### Other default animation types
```v
import spinners { Spinner, AnimationType }
import time

fn main() {
    mut sp := Spinner {
        animation: AnimationType.simple_dots
    }
    
    sp.start("please wait...") ?
    
    time.sleep(3000 * time.millisecond)
    
    // you can change text while it's running!
    sp.set_text("almost there! hang tight...")
    
    time.sleep(1000 * time.millisecond)
    
    sp.stop()
    println("done!")
}
```

### Customizing it's frames and interval
```v
import spinners { Spinner }
import time

fn main() {
    mut sp := Spinner {
        frames: [ 'a', 'b', 'c', 'd' ]
        interval: 80 // in ms
    }
    
    sp.start("please wait...") ?
    
    time.sleep(1000 * time.millisecond)
    
    sp.stop()
    println("done!")
}
```