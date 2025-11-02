//
//  File.swift
//
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation

public enum LogType: String{
    
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
}

public class Logger {
    
    fileprivate var logMessageBuilder:LogMessageBuilder
    fileprivate var displayTypes:[LogType] = [.info, .error, .todo, .warning] // .debug not included by default
    
    public init(category:String, subCategory:String, includeTypes:[LogType] = [], excludeTypes:[LogType] = []) {
        self.logMessageBuilder = LogMessageBuilder(category: category, subCategory: subCategory)
        
        if !includeTypes.isEmpty {
            for t in includeTypes {
                if let _ = self.displayTypes.firstIndex(of: t) {
                    // continue
                }else{
                    self.displayTypes.append(t)
                }
            }
        }
        
        if !excludeTypes.isEmpty {
            let defaultTypes:Set<LogType> = Set(self.displayTypes)
            let removeTypes:Set<LogType> = Set(excludeTypes)
            self.displayTypes = Array(defaultTypes.subtracting(removeTypes))
        }
    }
    
    private var destinationWriters:[String] = []
    private var writers:[String:LogWriter] = [:]
    
    
    private var _writers:[LogWriter] = []
    private func _getWriters() -> [LogWriter] {
        var list:[LogWriter] = []
        for dest in self.destinationWriters {
            if let writer = self.writers.first(where: { (key: String, value: LogWriter) in
                return key == dest
            }){
                list.append(writer.value)
            }
        }
        return list
    }
    private func getWriters() -> [LogWriter] {
        if self._writers.isEmpty {
            self._writers = self._getWriters()
        }
        return self._writers
    }
    
    private func write(_ msg:String, type:LogType = .info) {
        for writer in self.getWriters() {
//            print("\(writer.id()) -> cat:\(self.logMessageBuilder.getCategory()) type:\(type) -> \(LoggerFactory.isEnabled(category: self.logMessageBuilder.getCategory(), type: type))")
            if writer.isCategoryAvailable(self.logMessageBuilder.getCategory())
                && writer.isSubCategoryAvailable(self.logMessageBuilder.getSubCategory())
                && LoggerFactory.isEnabled(category: self.logMessageBuilder.getCategory(), type: type)
                && LoggerFactory.isEnabled(category: self.logMessageBuilder.getCategory(), subCategory: self.logMessageBuilder.getSubCategory(), type: type)
                && writer.isAnyKeywordMatched(msg) {
                        
                writer.write(message: msg)
            }
        }
    }
    
    public func timecost(_ message:String, fromDate:Date) {
        guard LoggerFactory.isEnabled(type: .performance) || self.displayTypes.contains(.performance) else {return}
        let msg = self.logMessageBuilder.build(logType: .performance, message: "\(message) - time cost: \(Date().timeIntervalSince(fromDate)) seconds", error: nil)
        self.write(msg)
    }
    
    public func log(_ message:String) {
        guard LoggerFactory.isEnabled(type: .info) || self.displayTypes.contains(.info) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:String) {
        guard LoggerFactory.isEnabled(type: logType) || self.displayTypes.contains(logType) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        self.write(msg, type: logType)
    }
    
    public func log(_ message:Int) {
        guard LoggerFactory.isEnabled(type: .info) || self.displayTypes.contains(.info) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg, type: .info)
    }
    
    public func log(_ logType:LogType, _ message:Int) {
        guard LoggerFactory.isEnabled(type: logType) || self.displayTypes.contains(logType) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        self.write(msg, type: logType)
    }
    
    public func log(_ message:Double) {
        guard LoggerFactory.isEnabled(type: .info) || self.displayTypes.contains(.info) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Double) {
        guard LoggerFactory.isEnabled(type: logType) || self.displayTypes.contains(logType) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        self.write(msg, type: logType)
    }
    
    public func log(_ message:Float) {
        guard LoggerFactory.isEnabled(type: .info) || self.displayTypes.contains(.info) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg)
    }
    public func log(_ logType:LogType, _ message:Float) {
        guard LoggerFactory.isEnabled(type: logType) || self.displayTypes.contains(logType) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        self.write(msg, type: logType)
    }
    
    public func log(_ message:Any) {
        guard LoggerFactory.isEnabled(type: .info) || self.displayTypes.contains(.info) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Any) {
        guard LoggerFactory.isEnabled(type: logType) || self.displayTypes.contains(logType) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        let logWriters = self.getWriters()
        for logger in logWriters {
            logger.write(message: msg)
        }
    }
    
    public func log(_ message:Error) {
        guard LoggerFactory.isEnabled(type: .info) || self.displayTypes.contains(.info) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: message)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Error) {
        guard LoggerFactory.isEnabled(type: logType) || self.displayTypes.contains(logType) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        let logWriters = self.getWriters()
        for writer in logWriters {
            writer.write(message: msg)
        }
    }
    
    public func log(_ message:String, _ error:Error) {
        guard LoggerFactory.isEnabled(type: .info) || self.displayTypes.contains(.info) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: error)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:String, _ error:Error) {
        guard LoggerFactory.isEnabled(type: logType) || self.displayTypes.contains(logType) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: error)
        self.write(msg, type: logType)
    }
}

extension Logger: LoggerRegister {
    
    public func registerWriter(id: String, writer:LogWriter) -> Self {
        self.writers[id] = writer
        let _ = self.addDestination(id)
        return self
    }
    
    public func addDestination(_ destination:String) -> Self {
        if !self.destinationWriters.contains(destination) {
            self.destinationWriters.append(destination)
        }
        return self
    }
    
    public func removeDestination(_ destination:String) -> Self {
        self.destinationWriters.removeAll { dest in
            return dest == destination
        }
        return self
    }
}

extension Logger : LoggerUser {
    
    public func loggingDestinations(_ destinations: [String]) -> Self {
        self.destinationWriters.append(contentsOf: destinations)
        return self
    }
    
    
    public func loggingCategory(category:String, subCategory:String) -> Self {
        self.logMessageBuilder = LogMessageBuilder(category: category, subCategory: subCategory)
        return self
    }
    
    public func excludeLoggingLevels(_ excludeTypes:[LogType] = []) -> Self {
        if !excludeTypes.isEmpty {
            let defaultTypes:Set<LogType> = Set(self.displayTypes)
            let removeTypes:Set<LogType> = Set(excludeTypes)
            self.displayTypes = Array(defaultTypes.subtracting(removeTypes))
        }
        return self
    }
    
    public func includeLoggingLevels(_ includeTypes:[LogType] = []) -> Self {
        if !includeTypes.isEmpty {
            for t in includeTypes {
                if let _ = self.displayTypes.firstIndex(of: t) {
                    // continue
                }else{
                    self.displayTypes.append(t)
                }
            }
        }
        return self
    }
    
}

public class LoggerFactory {
    
    fileprivate static var writers:[String:LogWriter] = [:]
    fileprivate static var types:[LogType] = []
    fileprivate static var categoryTypes:[String:[LogType]] = [:]
    
    public static func isEnabled(type:LogType) -> Bool {
        return types.contains(type)
    }
    
    public static func isEnabled(category:String, type:LogType) -> Bool {
        if isEnabled(type: type) { // is enabled globally
            let key = "\(category)##"
            if let types = categoryTypes[key] {
                print(">>> logger <<< \(category)## is \(types.contains(type))")
                return types.contains(type)
            }else{ // not defined means allowed
                return true
            }
        }else{
            
            return false
        }
    }
    
    public static func isEnabled(category:String, subCategory:String, type:LogType) -> Bool {
        if isEnabled(category: category, type: type) { // is enabled globally && is enabled parent category
            let key = "\(category)##\(subCategory)"
            print(">>> logger <<< \(category)##\(subCategory) is \(types.contains(type))")
            if let types = categoryTypes[key] {
                return types.contains(type)
            }else{ // not defined means allowed
                return true
            }
        }else{
            return false
        }
    }
    
    public static func getWriter(id:String) -> LogWriter? {
        return self.writers[id]
    }
    
    public static func append(logWriter:LogWriter) {
        Self.writers[logWriter.id()] = logWriter
    }
    
    public static func append(id:String, logWriter:LogWriter) {
        Self.writers[id] = logWriter
    }
    
    public static func remove(id:String) {
        Self.writers.removeValue(forKey: id)
    }
    
    public static func enable(_ types:[LogType]) {
        if !types.isEmpty {
            for t in types {
                if let _ = self.types.firstIndex(of: t) {
                    // continue
                }else{
                    self.types.append(t)
                }
            }
        }
    }
    
    public static func disable(_ types:[LogType]) {
        if !types.isEmpty {
            let defaultTypes:Set<LogType> = Set(self.types)
            let removeTypes:Set<LogType> = Set(types)
            self.types = Array(defaultTypes.subtracting(removeTypes))
        }
    }
    
    public static func enable(category:String, types:[LogType]) {
        let key = "\(category)##"
        categoryTypes[key] = types
    }
    
    public static func enable(category:String, subCategory:String, types:[LogType]) {
        let key = "\(category)##\(subCategory)"
        categoryTypes[key] = types
    }
    
    public static func get(category:String, subCategory:String = "", includeTypes:[LogType] = [], excludeTypes:[LogType] = [], destinations:[String] = [ConsoleLogger.id()]) -> Logger {
        let logger = Logger(category: category, subCategory: subCategory, includeTypes: includeTypes, excludeTypes: excludeTypes)
        for (id,writer) in writers {
            let _ = logger.registerWriter(id: id, writer: writer)
        }
        if !self.types.isEmpty {
            logger.displayTypes = self.types
        }
        return logger
    }
    
}
