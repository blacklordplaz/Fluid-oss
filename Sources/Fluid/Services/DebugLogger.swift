import Foundation
import SwiftUI
import Combine

class DebugLogger: ObservableObject {
    static let shared = DebugLogger()
    
    @Published var logs: [LogEntry] = []
    private let maxLogs = 1000 // Keep last 1000 log entries
    private let queue = DispatchQueue(label: "debug.logger", qos: .utility)
    
    struct LogEntry: Identifiable, Equatable {
        let id = UUID()
        let timestamp: Date
        let level: LogLevel
        let message: String
        let source: String
        
        var formattedTimestamp: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            return formatter.string(from: timestamp)
        }
    }
    
    enum LogLevel: String, CaseIterable {
        case info = "INFO"
        case warning = "WARN"
        case error = "ERROR"
        case debug = "DEBUG"
        
        var color: Color {
            switch self {
            case .info: return .blue
            case .warning: return .orange
            case .error: return .red
            case .debug: return .gray
            }
        }
    }
    
    private init() {}
    
    func log(_ message: String, level: LogLevel = .info, source: String = "App") {
        queue.async {
            let entry = LogEntry(timestamp: Date(), level: level, message: message, source: source)

            // Check if debug logging is enabled for debug level, but always show errors and warnings
            let shouldLogToConsole = level == .error || level == .warning || SettingsStore.shared.enableDebugLogs

            if shouldLogToConsole {
                // Also print to console for Xcode debugging
                print("[\(entry.formattedTimestamp)] [\(level.rawValue)] [\(source)] \(message)")
            }

            DispatchQueue.main.async {
                self.logs.append(entry)

                // Keep only the last maxLogs entries
                if self.logs.count > self.maxLogs {
                    self.logs.removeFirst(self.logs.count - self.maxLogs)
                }
            }
        }
    }
    
    func clear() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
    }
    
    func exportLogs() -> String {
        return logs.map { entry in
            "[\(entry.formattedTimestamp)] [\(entry.level.rawValue)] [\(entry.source)] \(entry.message)"
        }.joined(separator: "\n")
    }
}

// Convenience functions for easier logging
extension DebugLogger {
    func info(_ message: String, source: String = "App") {
        log(message, level: .info, source: source)
    }
    
    func warning(_ message: String, source: String = "App") {
        log(message, level: .warning, source: source)
    }
    
    func error(_ message: String, source: String = "App") {
        log(message, level: .error, source: source)
    }
    
    func debug(_ message: String, source: String = "App") {
        log(message, level: .debug, source: source)
    }
}