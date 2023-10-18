Search(){
    loop 4 {
        send {w down}{d down}{space down}
        hypersleep(300)
        send {space up}
        hypersleep(200)
        send {w up}{d up}
    }
    hypersleep(500)
    walk(2, "d")
    sendspace()
    hypersleep(200)
    loop 4 {
        send {d down}{space down}
        hypersleep(300)
        send {space up}
        hypersleep(200)
        send {d up}
    }
    walk(5, "d")
    sendspace()
    walk(8, "d")
    walk(3, "w")
    sendspace()
    hypersleep(200)
    loop 2 {
        send {w down}{space down}
        hypersleep(300)
        send {space up}
        hypersleep(200)
        send {w up}
    }
    hypersleep(500)
    send {w down}{space down}
    hypersleep(200)
    send {space up}
    hypersleep(1100)
    send {space down}
    hypersleep(200)
    send {space up}
    hypersleep(2000)
    send {w up}
    sendspace()
    HyperSleep(200)
    loop 2 {
        send {w down}{d down}{space down}
        hypersleep(300)
        send {space up}
        hypersleep(200)
        send {d up}{w up}
    }
    walk(3, "w", "d")
    sendspace()
    walk(24, "d")
    send {o 10}
    walk(2, "s")
    send {shift}{pgdn 2}
    /*
    here is where you would use a function to detect if there was a vicous in pepper
    this is best done by pixel search (ty xian) and using a lot of colous from an array
    if (vichere){
        return true
    } else {}
    go mt from here
    */
    hypersleep(1000)
    send {pgup 3}{. 5}
    hypersleep(200)
    send {w down}
    sendspace()
    sendspace()
    sendspace()
    send {w up}
    hypersleep(1700)
    send {w down}
    sendspace()
    sendspace()
    sendspace()
    hypersleep(1500)
    send {.}{shift}
    hypersleep(200)
    send {w up}
    sendspace()
    hypersleep(1200)
    send e
    hypersleep(2000)
    send {w down}
    sendSpace()
    sendSpace()
    hypersleep(1000)
    sendSpace()
    send {w up}
    hypersleep(1000)
    walk(8.5, "s", "a")
    send {. 2}
    walk(8.5, "s")
    send {shift}{pgdn 4}
    /*
    here is where you would use a function to detect if there was a vicous in mountain top
    this is best done by pixel search (ty xian) and using a lot of colous from an array
    if (vichere){
        return true
    } else {}
    go spider from here
    */
    hypersleep(1000)
    send {shift}{pgup 3}
    walk(12, "w", "a")
    walk(11, "w")
    sendSpace()
    send {w down}
    sendSpace()
    sendSpace()
    hypersleep(3000)
    send {w up}
    sendSpace()
    hypersleep(1500)
    send {. 2}
    loop 4 {
        send {w down}{space down}
        hypersleep(300)
        send {space up}
        hypersleep(200)
        send {w up}
    }
    hypersleep(200)
    walk(10, "w")
    walk(9, "d")
    send {shift}{pgdn 2}
    /*
    here is where you would use a function to detect if there was a vicous in mountain top
    this is best done by pixel search (ty xian) and using a lot of colous from an array
    if (vichere){
        return true
    } else {}
    go cactus from here
    */
    hypersleep(1000)
    send {shift}{pgup 2}
    hypersleep(200)
    walk(4, "a")
    send {w down}
    sendspace()
    walk_(7)
    send {w up}
    walk(14, "d")
    loop 4 {
        send {w down}{d down}{space down}
        hypersleep(300)
        send {space up}
        hypersleep(200)
        send {w up}{d up}
    }
    walk(12, "w", "d")
    hypersleep(200)
    send {w down}
    sendspace()
    walk_(9)
    send {w up}
    send {shift}{pgdn 3}
    /*
    here is where you would use a function to detect if there was a vicous in rose
    this is best done by pixel search (ty xian) and using a lot of colous from an array
    if (vichere){
        return true
    } else {}
    go rose from here
    */
    hypersleep(1000)
    send {shift}
    hypersleep(200)
    send {w down}
    hypersleep(500)
    send {a down}
    loop 4 {
        send {space down}
        hypersleep(300)
        send {space up}
        hypersleep(200)
    }
    hypersleep(1000)
    send {w up}{a up}
    walk(7, "a")
    sendspace()
    send {a down}
    walk(18, "a")
    send {, 2}{pgup 4}
    walk(10, "d")
    send {shift}{pgdn 4}
}