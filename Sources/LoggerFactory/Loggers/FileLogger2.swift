//
//  FileLogger.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2026/3/28.
//  Copyright © 2026 nonamecat. All rights reserved.
//

import Foundation

public class FileLogger2 : LogWriter2, Codable {
    
    private var _id = ""
    private var _folder = ""
    private var _filename = ""
    
    private var _forCategory = ""
    private var _forSubCategory = ""
    private var _forLogType:[LogType] = []
    
    public init(id:String, folder:String, filename:String, forCategory:String = "", forSubCategory:String = "", forLogType:[LogType] = []) {
        self._id = id
        self._folder = folder
        self._filename = filename
        
        self._forCategory = forCategory
        self._forSubCategory = forSubCategory
        self._forLogType = forLogType
    }
    
    public func id() -> String {
        return self._id
    }
    
    public func file() -> String {
        return URL(fileURLWithPath: self._folder).appending(path: self._filename).path()
    }
    
    public func write(message: String) {
        print(message)
    }
    
    public func isMatched(category:String, subCategory:String, logType:[LogType]) -> Bool {
        if self._forCategory == "" {
            if !Set(self._forLogType).intersection(Set(logType)).isEmpty {
                return true
            }else{
                return false
            }
        }else{
            if self._forCategory == category {
                if self._forSubCategory == "" {
                    if !Set(self._forLogType).intersection(Set(logType)).isEmpty {
                        return true
                    }else{
                        return false
                    }
                }else{
                    if self._forSubCategory == subCategory {
                        if !Set(self._forLogType).intersection(Set(logType)).isEmpty {
                            return true
                        }else{
                            return false
                        }
                    }else{
                        return false
                    }
                }
            }else{
                return false
            }
        }
    }
    
    public func toJSON() -> String {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            return json ?? "{}"
        }catch{
            ConsoleLogger2.default.error("\(error)")
            return "{}"
        }
    }
}
