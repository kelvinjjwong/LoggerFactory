//
//  File.swift
//
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation


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
