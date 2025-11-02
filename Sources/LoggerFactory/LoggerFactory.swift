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
    
    public static func all() -> [LogType] {
        return [LogType.error, LogType.warning, LogType.info, LogType.debug, LogType.todo, LogType.trace, LogType.performance]
    }
}

public class Logger {
    
    fileprivate var logMessageBuilder:LogMessageBuilder
    fileprivate var displayTypes:[LogType] = [.info, .error, .todo, .warning] // .debug not included by default
    
    private var _category = ""
    private var _subCategory = ""
    
    public init(category:String, subCategory:String, types:[LogType] = []) {
        self._category = category
        self._subCategory = subCategory
        self.logMessageBuilder = LogMessageBuilder(category: category, subCategory: subCategory)
        
        if !types.isEmpty {
            for t in types {
                if let _ = self.displayTypes.firstIndex(of: t) {
                    // continue
                }else{
                    self.displayTypes.append(t)
                }
            }
        }
        
//        if !excludeTypes.isEmpty {
//            let defaultTypes:Set<LogType> = Set(self.displayTypes)
//            let removeTypes:Set<LogType> = Set(excludeTypes)
//            self.displayTypes = Array(defaultTypes.subtracting(removeTypes))
//        }
    }
    
    private var destinationWriters:[String] = []
    private var writers:[String:LogWriter] = [:]
    
    public func printWriters() {
        for (id, _) in writers {
            print("logger registered writer: \(id)")
        }
    }
    
    
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
            writer.write(message: msg)
        }
    }
    
    public func timecost(_ message:String, fromDate:Date) {
        guard self.displayTypes.contains(.performance) && LoggerFactory.isLogTypeEnabled(.performance, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .performance, message: "\(message) - time cost: \(Date().timeIntervalSince(fromDate)) seconds", error: nil)
        self.write(msg)
    }
    
    public func log(_ message:String) {
        guard self.displayTypes.contains(.info) && LoggerFactory.isLogTypeEnabled(.info, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:String) {
//        print("\(logType) contains? \(self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory))")
        guard self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        self.write(msg, type: logType)
    }
    
    public func log(_ message:Int) {
        guard self.displayTypes.contains(.info) && LoggerFactory.isLogTypeEnabled(.info, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg, type: .info)
    }
    
    public func log(_ logType:LogType, _ message:Int) {
        guard self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        self.write(msg, type: logType)
    }
    
    public func log(_ message:Double) {
        guard self.displayTypes.contains(.info) && LoggerFactory.isLogTypeEnabled(.info, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Double) {
        guard self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        self.write(msg, type: logType)
    }
    
    public func log(_ message:Float) {
        guard self.displayTypes.contains(.info) && LoggerFactory.isLogTypeEnabled(.info, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg)
    }
    public func log(_ logType:LogType, _ message:Float) {
        guard self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        self.write(msg, type: logType)
    }
    
    public func log(_ message:Any) {
        guard self.displayTypes.contains(.info) && LoggerFactory.isLogTypeEnabled(.info, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Any) {
        guard self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        let logWriters = self.getWriters()
        for logger in logWriters {
            logger.write(message: msg)
        }
    }
    
    public func log(_ message:Error) {
        guard self.displayTypes.contains(.info) && LoggerFactory.isLogTypeEnabled(.info, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: message)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Error) {
        guard self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        let logWriters = self.getWriters()
        for writer in logWriters {
            writer.write(message: msg)
        }
    }
    
    public func log(_ message:String, _ error:Error) {
        guard self.displayTypes.contains(.info) && LoggerFactory.isLogTypeEnabled(.info, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: error)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:String, _ error:Error) {
        guard self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory) else {return}
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
    
    fileprivate static var all_writers:[String:LogWriter] = [:] // writer_id : writer_object
    fileprivate static var cover_all_writers:[String:LogWriter] = [:] // writer_id : writer_object
    fileprivate static var cover_special_writers:[String:LogWriter] = [:] // writer_id : writer_object
    fileprivate static var category_writers:[String:[String]] = [:] // "LogType:category##subcategory" : [writer_id]
    fileprivate static var category_logTypes:[String:[LogType]] = [:] // "_##category##subcategory" : [LogType]
//    fileprivate static var types:[LogType] = [] // [type_enum]
//    fileprivate static var categoryTypes:[String:[LogType]] = [:] // category: [type_enum]
    
    
    
    public static func getWriter(id:String) -> LogWriter? {
        return self.all_writers[id]
    }
    
    public static func append(logWriter:LogWriter, coverAll:Bool = true) {
        LoggerFactory.all_writers[logWriter.id()] = logWriter
        print("✜ LoggerFactory.append writer:\(logWriter.id()) coverAll:\(coverAll)")
        if coverAll == true {
            LoggerFactory.cover_all_writers[logWriter.id()] = logWriter
        }else{
            LoggerFactory.cover_special_writers[logWriter.id()] = logWriter
        }
        var exist_writers = LoggerFactory.category_writers["_"] ?? []
        exist_writers.append(logWriter.id())
        
    }
    
    public static func remove(id:String) {
        LoggerFactory.all_writers.removeValue(forKey: id)
        LoggerFactory.cover_all_writers.removeValue(forKey: id)
        LoggerFactory.cover_special_writers.removeValue(forKey: id)
    }
    
    public static func removeAll() {
        LoggerFactory.all_writers.removeAll()
        LoggerFactory.cover_all_writers.removeAll()
        LoggerFactory.cover_special_writers.removeAll()
        LoggerFactory.category_writers.removeAll()
    }
    
    public static func getKey(type:LogType, category:String, subCategory:String) -> String {
        if category == "" && subCategory == "" {
            return "\(type)"
        }else if subCategory == "" {
            return "\(type):\(category)##"
        }else{
            return "\(type):\(category)##\(subCategory)"
        }
    }
    
    public static func getKey(category:String, subCategory:String) -> String {
        if category == "" && subCategory == "" {
            return "_"
        }else if subCategory == "" {
            return "_##\(category)##"
        }else{
            return "_##\(category)##\(subCategory)"
        }
    }
    
    public static func enable(_ types:[LogType], writers:[String] = ["_"]) {
        let _types = types.count > 0 ? types : LogType.all()
        for t in _types {
            let key = getKey(type: t, category: "", subCategory: "")
            category_writers[key] = writers
            print("logger registered for \(key) with \(writers)")
        }
        let key_ = getKey(category: "", subCategory: "")
        category_logTypes[key_] = types
        print("logger registered for type:\(key_) with \(types)")
    }
    
    public static func enable(category:String, types:[LogType], writers:[String] = ["_"]) {
        let _types = types.count > 0 ? types : LogType.all()
        for t in _types {
            let key = getKey(type: t, category: category, subCategory: "")
            category_writers[key] = writers
            print("logger registered for \(key) with writers:\(writers)")
        }
        let key_ = getKey(category: category, subCategory: "")
        category_logTypes[key_] = types
        print("logger registered for type:\(key_) with \(types)")
    }
    
    public static func enable(category:String, subCategory:String, types:[LogType], writers:[String] = ["_"]) {
        let _types = types.count > 0 ? types : LogType.all()
        for t in _types {
            let key = getKey(type: t, category: category, subCategory: subCategory)
            category_writers[key] = writers
            print("logger registered for \(key) with writers:\(writers)")
        }
        let key_ = getKey(category: category, subCategory: subCategory)
        category_logTypes[key_] = types
        print("logger registered for type:\(key_) with \(types)")
    }
    
    public static func isLogTypeEnabled(_ type:LogType, category:String, subCategory:String) -> Bool {
        let key_1 = getKey(category: category, subCategory: subCategory)
        let key_2 = getKey(category: category, subCategory: "")
        let key_3 = getKey(category: "", subCategory: "")
//        print("checking logtype enabled: \(type) - \(key_1)")
        if let enabled = category_logTypes[key_1] {
            return enabled.contains(type)
        }else if let enabled = category_logTypes[key_2] {
            return enabled.contains(type)
        }else if let enabled = category_logTypes[key_3] {
            return enabled.contains(type)
        }else{
            return false
        }
    }
    
    public static func get(category:String, subCategory:String = "", types:[LogType] = [], separated:Bool = false) -> Logger {
        let _types = types.count > 0 ? types : LogType.all()
        
        let logger = Logger(category: category, subCategory: subCategory, types: _types)
        
        for t in _types {
            var writers_id:Set<String> = []
            
            let key1 = getKey(type: t, category: category, subCategory: subCategory)
            let key2 = getKey(type: t, category: category, subCategory: "")
            let key3 = getKey(type: t, category: "", subCategory: "")
            let ids1 = category_writers[key1] ?? []
            let ids2 = category_writers[key2] ?? []
            let ids3 = category_writers[key3] ?? []
            let maxCount = max(ids1.count, ids2.count, ids3.count)
            var ids:[String] = []
            if maxCount == ids1.count {
                ids = ids1
            }
            else if maxCount == ids2.count {
                ids = ids2
            }
            else if maxCount == ids3.count {
                ids = ids3
            }
//            print("LoggerFactory.get_\(key1)")
//            print("ids=\(ids)")
            if ids.count == 1 && ids[0] == "_" {
                for (id, _) in cover_all_writers {
                    if !writers_id.contains(id) {
                        writers_id.insert(id)
//                        print("LoggerFactory.get_\(key1)_insert1 writer id:\(id)")
                    }
                }
            }else{
                for id in ids {
                    if !writers_id.contains(id) {
                        writers_id.insert(id)
//                        print("LoggerFactory.get_\(key1)_insert2 writer id:\(id)")
                    }
                }
            }
            if !separated {
                for (id, _) in cover_all_writers {
                    if !writers_id.contains(id) {
                        writers_id.insert(id)
//                        print("LoggerFactory.get_\(key1)_insert3 writer id:\(id)")
                    }
                }
            }
            
            for writer_id in writers_id {
                if let writer = all_writers[writer_id] {
                    let _ = logger.registerWriter(id: writer_id, writer: writer)
                }
            }
        }
        return logger
    }
    
}
