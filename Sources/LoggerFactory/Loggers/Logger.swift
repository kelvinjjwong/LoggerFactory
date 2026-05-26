//
//  Logger.swift
//  LoggerFactory
//
//  Created by Kelvin Wong on 2026/5/26.
//

import Foundation

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
