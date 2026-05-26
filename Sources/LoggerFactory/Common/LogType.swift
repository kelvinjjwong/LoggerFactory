//
//  LogType.swift
//  LoggerFactory
//
//  Created by Kelvin Wong on 2026/5/26.
//


public enum LogType: String, Codable {
    
    public static func iconOfType(_ logType:LogType) -> String {
        switch logType {
        case LogType.error:
            return "📕"
        case LogType.warning:
            return "📙"
        case LogType.debug:
            return "👻"
        case LogType.todo:
            return "⚠️"
        case LogType.trace:
            return "🐢"
        case LogType.performance:
            return "🕘"
        default:
            return "📗"
        }
    }
    
    case error
    case warning
    case info
    case debug
    case todo
    case trace
    case performance
    
    public static func all() -> [LogType] {
        return [LogType.error, LogType.warning, LogType.info, LogType.debug, LogType.todo, LogType.trace, LogType.performance]
    }
}
