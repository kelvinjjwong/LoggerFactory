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
    
    public func timecost(_ message:String, fromDate:Date) async {
        let msg = self.logMessageBuilder.build(logType: .performance, message: "\(message) - time cost: \(Date().timeIntervalSince(fromDate)) seconds", error: nil)
        await self.write(msg)
    }
    
    public func log(_ message:String) async {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        await self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:String) async {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        await self.write(msg, type: logType)
    }
    
    public func log(_ message:Int) async {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        await self.write(msg, type: .info)
    }
    
    public func log(_ logType:LogType, _ message:Int) async {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        await self.write(msg, type: logType)
    }
    
    public func log(_ message:Double) async {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        await self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Double) async {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        await self.write(msg, type: logType)
    }
    
    public func log(_ message:Float) async {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        await self.write(msg)
    }
    public func log(_ logType:LogType, _ message:Float) async {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        await self.write(msg, type: logType)
    }
    
    public func log(_ message:Any) async {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        await self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Any) async {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        await self.write(msg)
    }
    
    public func log(_ message:Error) async {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: message)
        await self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Error) async {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        await self.write(msg)
    }
    
    public func log(_ message:String, _ error:Error) async {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: error)
        await self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:String, _ error:Error) async {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: error)
        await self.write(msg, type: logType)
    }
}
