//
//  Logger.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2026/3/28.
//  Copyright © 2026 nonamecat. All rights reserved.
//

import Foundation

public protocol LogWriterFinder {
    
    func findWriter(id: String) -> LogWriter2?
}

public class LoggerFactory2 {
    public static let `default` = LoggerFactory2()
    
    fileprivate var _registered_category_to_writer_ids:[String:[String]] = [:]
    fileprivate var _writers:[String:LogWriter2] = [:] // writer_id : writer_object
    
    private func findWriters(type:LogType, category:String, subCategory:String) -> [String] {
        let key = LoggerFactory.getKey(type: type, category: category, subCategory: subCategory)
        ConsoleLogger2.default.log("find log writer for key: \(key)")
        return _registered_category_to_writer_ids[key] ?? []
    }
    
    private func addWriter(type:LogType, category:String, subCategory:String, writerId:String) {
        let key = LoggerFactory.getKey(type: type, category: category, subCategory: subCategory)
        if _registered_category_to_writer_ids[key] == nil {
            _registered_category_to_writer_ids[key] = [writerId]
        }else{
            if var list = _registered_category_to_writer_ids[key] {
                if !list.contains(writerId) {
                    list.append(writerId)
                    
                    _registered_category_to_writer_ids[key] = list
                }
            }
        }
    }
    
    public func registerConsoleLogger() {
        let consoleLogger = ConsoleLogger2()
        _writers[consoleLogger.id()] = consoleLogger
        ConsoleLogger2.default.log("registered logger: console")
    }
    
    public func registerFileLogger(id:String, folder:String, filename:String, forCategory:String = "", forSubCategory:String = "", forLogType:[LogType] = []) {
        let fileLogger = FileLogger2(id: id, folder: folder, filename: filename, forCategory: forCategory, forSubCategory: forSubCategory, forLogType: forLogType)
        _writers[fileLogger.id()] = fileLogger
        ConsoleLogger2.default.log("registered logger: \(fileLogger.toJSON())")
    }
    
    public func get(category:String, subCategory:String = "", types:[LogType] = []) -> Logger2 {
        let _types = types.count > 0 ? types : LogType.all()
        
        let logger = Logger2(finder:self, category: category, subCategory: subCategory, types: _types)
        
        for t in _types {
            var writers_id:Set<String> = []
            
            var writers = self.findWriters(type: t, category: category, subCategory: subCategory)
            if writers.count == 0 {
                writers = self.findWriters(type: t, category: category, subCategory: "")
                if writers.count == 0 {
                    writers = self.findWriters(type: t, category: "", subCategory: "")
                }
            }
            if writers.count == 0 {
                // create writer
                
            }
            
            ConsoleLogger2.default.log("found \(writers.count) log writers")
            for writer in writers {
                if !writers_id.contains(writer) {
                    writers_id.insert(writer)
                }
            }
            
            ConsoleLogger2.default.log("checking \(t)")
            
            for writer_id in writers_id {
                if let _writer = _writers[writer_id] {
                    logger.registerWriter(id: writer_id)
                    
                    LoggerSetting2.default.addSetting(logtype: t, category: category, subCategory: subCategory, writerId: writer_id)
                }
            }
        }
        return logger
    }
}

extension LoggerFactory2 : LogWriterFinder {
    public func findWriter(id: String) -> (any LogWriter2)? {
        return self._writers[id]
    }
    
}
