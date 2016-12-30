import Foundation
import CNCurses

#if os(macOS)
    import Darwin
    typealias SignalHandler = @convention(c) (Int32) -> Swift.Void
#else
     typealias SignalHandler = __sighandler_t
#endif

enum Signal: Int32 {
    case INT   = 2
    case WINCH = 28
}

func trap(_ signum: Signal, action: @escaping SignalHandler) {
    signal(signum.rawValue, action)
}

trap(.INT) { signal in
    endwin()
    exit(1)
}
trap(.WINCH) { signal in
    // handle resize
}

@discardableResult
func printw(_ str: String) -> Int32 {
    return addstr(str)
}

@discardableResult
func mvprintw(y:Int32, x:Int32, str:String) -> Int32 {
    move(y, x)
    return addstr(str)
}


initscr();          /* Start curses mode        */
cbreak()
keypad(stdscr, true);       /* We get F1, F2 etc..      */
//noecho();           /* Don't echo() while we do getch */

//mousemask(NC_ALL_MOUSE_EVENTS | NC_REPORT_MOUSE_POSITION, nil)

//while true {
//    var c = wgetch(stdscr)
// 
//    // Exit the program on new line feed
//    if (c == 10) {
//      break;
//    }
// 
////    move(0, 0)
//    if (c == ERR) {
//        printw("Nothing happened")
//    } else if (c == KEY_MOUSE) {
//        var event = MEVENT()
////      var event: UnsafeMutablePointer<MEVENT>? = nil
//      if (getmouse(&event) == OK) {
//        // snprintf(buffer, max_size, "Mouse at row=%d, column=%d bstate=0x%08lx",
//        //          event.y, event.x, event.bstate);
////        event?.pointee.
//        printw("Mouse at \(event.y), \(event.x), \(event.bstate)")
//      }
//      else {
//        printw("Got bad mouse event.")
//      }
//    }
//    else {
//      printw("Pressed key \(c) (\(keyname(c)))")
//    }
//
//    clrtoeol()
//    refresh()
//  }

  // printf("\033[?1003l\n"); // Disable mouse movement events, as l = low

start_color()
init_pair(1, Int16(COLOR_WHITE), Int16(COLOR_BLUE))
init_pair(2, Int16(COLOR_WHITE), Int16(COLOR_RED))

bkgd(chtype(COLOR_PAIR(1)))
border(0, 0, 0, 0, 0, 0, 0, 0)

mvaddstr(2, 2, "What would you like to do today?")
refresh()

attron(COLOR_PAIR(2))
mvaddstr(10, 10, String(repeating: " ", count: 60))
var input = Data(count: 60)
_ = input.withUnsafeMutableBytes {
    mvgetnstr(10, 10, $0, Int32(input.count))
}

endwin();

print(String(data: input, encoding: .utf8) ?? "unparseable")
