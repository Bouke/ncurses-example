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
    endwin()
    print("resizes are not supported, quitting")
    exit(1)
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

start_color()
init_pair(1, Int16(COLOR_WHITE), Int16(COLOR_MAGENTA))
init_pair(2, Int16(COLOR_WHITE), Int16(COLOR_RED))
init_pair(3, Int16(COLOR_BLACK), Int16(COLOR_WHITE))
init_pair(4, Int16(COLOR_RED), Int16(COLOR_WHITE))

bkgd(chtype(COLOR_PAIR(1)))
clear()
refresh()

func prompt(title: String, message: String) -> String? {
    let promptXY = renderPrompt(title: title, message: message)

    var input = Data(count: Int(promptXY.width))
    _ = input.withUnsafeMutableBytes {
        mvwgetnstr(promptXY.win, promptXY.y, promptXY.x, $0, promptXY.width)
    }

    return String(data: input, encoding: .utf8)
}

func renderPrompt(title: String, message: String) -> (win: OpaquePointer, y: Int32, x: Int32, width: Int32) {
    let marginX: Int32 = 3
    let paddingX: Int32 = 1
    let width: Int32 = getmaxx(stdscr) - 2 * marginX
    let innerWidth = width - 2 - 2 * paddingX

    var text = message
    wrapText(&text, at: Int(innerWidth))
    let lines = text.components(separatedBy: .newlines)

    let paddingY: Int32 = 1
    let innerHeight = Int32(lines.count) + 4
    let height = innerHeight + 4
    let marginY = (getmaxy(stdscr) - height) / 2

    let win = newwin(height, width, marginY, marginX)!

    wbkgd(win, chtype(COLOR_PAIR(3)))
    box(win, 0, 0)
    for (i, line) in lines.enumerated() {
        mvwaddstr(win, 1 + paddingY + Int32(i), 1 + paddingX, line)
    }

    let titleX = (width - title.utf8.count) / 2
    mvwaddstr(win, 0, titleX - 2, "| ")
    mvwaddstr(win, 0, titleX + title.utf8.count, " |")

    mvwaddstr(win, innerHeight + 1, 6, "<Go Back>")
    mvwaddstr(win, innerHeight + 1, innerWidth - 12, "<Continue>")

    wattron(win, COLOR_PAIR(4))
    mvwaddstr(win, 0, titleX, title)

    wattron(win, COLOR_PAIR(1))
    let inputY = innerHeight - 1
    mvwaddstr(win, inputY, 1 + paddingX, String(repeating: "_", count: Int(innerWidth)))

    wrefresh(win)
    return (win, inputY, 1 + paddingX, innerWidth)
}

func wrapText(_ text: inout String, at width: Int) {
    var startIndex = text.startIndex
    while startIndex < text.endIndex {
        guard let endIndex = text.index(startIndex, offsetBy: width, limitedBy: text.endIndex) else {
            return
        }
        let range = Range<String.Index>(uncheckedBounds: (startIndex, endIndex))
        if let newline = text.rangeOfCharacter(from: .newlines, options: [.backwards], range: range) {
            startIndex = newline.upperBound
            continue
        }
        let space = text.rangeOfCharacter(from: .whitespaces, options: [.backwards], range: range)!
        text.replaceSubrange(space, with: "\n")
        startIndex = space.upperBound
    }
}

_ = prompt(title: "[!] Configure the network", message: "Please enter the hostname for this system.\n\nThe hostname is a single word that identifies your system to the network. If you don't know what your hostname should be, consult your network administrator. If you are setting up your own home network, you can make something up here.\n\nHostname:")

endwin();
