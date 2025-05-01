import Foundation
import Darwin.POSIX
// Import correct header for fd_set functions
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

// Terminal Handler class for handling terminal input and output
class TerminalHandler {
    private var originalTermios: termios?
    
    // MARK: - Initializer and Deinitializer
    
    init() {
        setRawMode()
    }
    
    deinit {
        restoreTerminalSettings()
    }
    
    // MARK: - Terminal Mode Control
    
    // Set terminal to raw mode to capture individual keystrokes
    func setRawMode() {
        var raw = termios()
        tcgetattr(STDIN_FILENO, &raw)
        
        // Save original settings
        originalTermios = raw
        
        // Modify terminal settings for raw mode
        raw.c_lflag &= ~(UInt(ECHO | ICANON | ISIG))
        
        // Set minimum bytes and timeout
        raw.c_cc.16 = 0  // VMIN = 0: return immediately, even if no bytes available
        raw.c_cc.17 = 1  // VTIME = 1: timeout after 0.1 seconds
        
        // Apply settings
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw)
    }
    
    // Restore terminal to original settings
    func restoreTerminalSettings() {
        if var original = originalTermios {
            tcsetattr(STDIN_FILENO, TCSAFLUSH, &original)
        }
    }
    
    // MARK: - Input Methods
    
    // Read a keystroke from the terminal and interpret escape sequences
    func readKeystroke() -> Keystroke? {
        var buffer = [UInt8](repeating: 0, count: 8)
        let bytesRead = read(STDIN_FILENO, &buffer, buffer.count)
        
        if bytesRead <= 0 {
            return nil
        }
        
        // Simple key
        if bytesRead == 1 {
            switch buffer[0] {
            case 13:
                return .enter
            case 27:
                return .escape
            case 32:
                return .space
            case 127:
                return .backspace
            case 9:
                return .tab
            case 113:
                return .character("q")
            case 98:
                return .character("b")
            default:
                if buffer[0] >= 32 && buffer[0] <= 126 {
                    // Printable ASCII character
                    if let char = String(bytes: [buffer[0]], encoding: .ascii) {
                        return .character(char)
                    }
                }
                return .other(Int(buffer[0]))
            }
        }
        
        // Escape sequence (e.g., arrow keys)
        if bytesRead >= 3 && buffer[0] == 27 && buffer[1] == 91 {
            switch buffer[2] {
            case 65:
                return .arrowUp
            case 66:
                return .arrowDown
            case 67:
                return .arrowRight
            case 68:
                return .arrowLeft
            default:
                return .other(Int(buffer[2]))
            }
        }
        
        return nil
    }
    
    // Wait for a key press with timeout - simpler implementation
    func waitForKeystroke(timeout: TimeInterval = 0.1) -> Keystroke? {
        // Simple implementation: just try to read directly
        // The raw mode setting with proper VTIME value handles the timeout
        return readKeystroke()
    }
}

// Enum for keystrokes
enum Keystroke {
    case arrowUp
    case arrowDown
    case arrowLeft
    case arrowRight
    case enter
    case escape
    case space
    case tab
    case backspace
    case character(String)
    case other(Int)
} 