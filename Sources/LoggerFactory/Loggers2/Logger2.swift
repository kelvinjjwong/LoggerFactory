//
//  Protocol.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2026/3/28.
//  Copyright © 2026 nonamecat. All rights reserved.
//
import Cocoa

public protocol LogWriter2 {
    func id() -> String
    func write(message: String) async
    func file() -> String
    
    func getForLogType() -> [LogType]
    func getForCategory() -> String
    func getForSubCategory() -> String
}


public class Logger2 {
    
    fileprivate var logMessageBuilder:LogMessageBuilder
    fileprivate var displayTypes:[LogType] = [.info, .error, .todo, .warning] // .debug not included by default
    
    private var _category = ""
    private var _subCategory = ""
    
    private var writerFinder:LogWriterFinder?
    
    public init(finder:LogWriterFinder, category:String, subCategory:String, types:[LogType] = []) {
        self.writerFinder = finder
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
    }
    
    private func write(_ msg:String, type:LogType = .info) async {
        if let finder = self.writerFinder {
            let writerIds = finder.findWriters(type: type, category: self._category, subCategory: self._subCategory)
            
            for writerId in writerIds {
                if let writer = finder.findWriter(id: writerId) {
                    await writer.write(message: msg)
                }
            }
        }
    }
    
    public func timecost(_ message:String, fromDate:Date, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: .performance, message: "\(message) - time cost: \(Date().timeIntervalSince(fromDate)) seconds", error: nil, fileID: fileID, function: function, line: line)
        await self.write(msg)
    }
    
    public func log(_ message:String, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil, fileID: fileID, function: function, line: line)
        await self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:String, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil, fileID: fileID, function: function, line: line)
        await self.write(msg, type: logType)
    }
    
    public func log(_ message:Int, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil, fileID: fileID, function: function, line: line)
        await self.write(msg, type: .info)
    }
    
    public func log(_ logType:LogType, _ message:Int, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil, fileID: fileID, function: function, line: line)
        await self.write(msg, type: logType)
    }
    
    public func log(_ message:Double, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil, fileID: fileID, function: function, line: line)
        await self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Double, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        await self.write(msg, type: logType)
    }
    
    public func log(_ message:Float, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        await self.write(msg)
    }
    public func log(_ logType:LogType, _ message:Float, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil, fileID: fileID, function: function, line: line)
        await self.write(msg, type: logType)
    }
    
    public func log(_ message:Any, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil, fileID: fileID, function: function, line: line)
        await self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Any, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil, fileID: fileID, function: function, line: line)
        await self.write(msg)
    }
    
    public func log(_ message:Error, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: message, fileID: fileID, function: function, line: line)
        await self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Error, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil, fileID: fileID, function: function, line: line)
        await self.write(msg)
    }
    
    public func log(_ message:String, _ error:Error, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: error, fileID: fileID, function: function, line: line)
        await self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:String, _ error:Error, fileID: String = #fileID, function: String = #function, line: Int = #line) async {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: error, fileID: fileID, function: function, line: line)
        await self.write(msg, type: logType)
    }
}
