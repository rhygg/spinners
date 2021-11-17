# Spinners in Vlang

```v
import spinners { Spinner }
import time

fn main() {
    mut sp := Spinner{}
    sp.start("line", "please wait...") ?
    
    // ... do stuff ... //
    
    time.sleep(1000 * time.millisecond)
    
    sp.stop() ?
    println("done!")
}
```

Check out all the spinners in the [`spinners_condensed.json`](https://github.com/rhygg/spinners/blob/master/spinners_condensed.json) file!
