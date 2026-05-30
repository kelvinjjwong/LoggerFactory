//
//  File.swift
//  
//
//  Created by kelvinwong on 2023/7/19.
//


import Foundation

protocol LogMessageBuilderInterface {
    func build(logType:LogType, message:String, error:Error?, fileID: String, function: String, line: Int) -> String
    func build(logType:LogType, message:Int, error:Error?, fileID: String, function: String, line: Int) -> String
    func build(logType:LogType, message:Double, error:Error?, fileID: String, function: String, line: Int) -> String
    func build(logType:LogType, message:Float, error:Error?, fileID: String, function: String, line: Int) -> String
    func build(logType:LogType, message:Any, error:Error?, fileID: String, function: String, line: Int) -> String
    func build(logType:LogType, error:Error, fileID: String, function: String, line: Int) -> String
}

public class LogMessageBuilder : LogMessageBuilderInterface {
    
    private let dtFormatter = ISO8601DateFormatter()
    
    private var category:String = ""
    private var subCategory:String = ""
    
    public func getCategory() -> String {
        return self.category
    }
    
    public func getSubCategory() -> String {
        return self.subCategory
    }
    
    public init(category:String, subCategory:String) {
        self.category = category
        self.subCategory = subCategory
    }
    
    fileprivate func prefix(category:String, subCategory:String, fileID: String = #fileID, function: String = #function, line: Int = #line) -> String {
        if subCategory == "" {
            return "\(LoggerSetting2.dateTimeFormat().string(from: Date())) [\(fileID.replacingOccurrences(of: ".swift", with: "", options: .backwards))#\(function):\(line)] [\(category)]"
        }else{
            return "\(LoggerSetting2.dateTimeFormat().string(from: Date())) [\(fileID.replacingOccurrences(of: ".swift", with: "", options: .backwards))#\(function):\(line)] [\(category)][\(subCategory)]"
        }
    }
    
    public func build(logType:LogType, message:String, error:Error?, fileID: String = #fileID, function: String = #function, line: Int = #line) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.error)) \(self.prefix(category: category, subCategory: subCategory, fileID: fileID, function: function, line: line)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(logType)) \(self.prefix(category: category, subCategory: subCategory, fileID: fileID, function: function, line: line)) \(message)"
        }
    }
    
    public func build(logType:LogType, message:Int, error:Error?, fileID: String = #fileID, function: String = #function, line: Int = #line) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.error)) \(self.prefix(category: category, subCategory: subCategory, fileID: fileID, function: function, line: line)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(logType)) \(self.prefix(category: category, subCategory: subCategory, fileID: fileID, function: function, line: line)) \(message)"
        }
    }
    
    public func build(logType:LogType, message:Double, error:Error?, fileID: String = #fileID, function: String = #function, line: Int = #line) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.error)) \(self.prefix(category: category, subCategory: subCategory, fileID: fileID, function: function, line: line)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(logType)) \(self.prefix(category: category, subCategory: subCategory, fileID: fileID, function: function, line: line)) \(message)"
        }
    }
    
    public func build(logType:LogType, message:Float, error:Error?, fileID: String = #fileID, function: String = #function, line: Int = #line) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.error)) \(self.prefix(category: category, subCategory: subCategory, fileID: fileID, function: function, line: line)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(logType)) \(self.prefix(category: category, subCategory: subCategory, fileID: fileID, function: function, line: line)) \(message)"
        }
    }
    
    public func build(logType:LogType, message:Any, error:Error?, fileID: String = #fileID, function: String = #function, line: Int = #line) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.error)) \(self.prefix(category: category, subCategory: subCategory, fileID: fileID, function: function, line: line)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(logType)) \(self.prefix(category: category, subCategory: subCategory, fileID: fileID, function: function, line: line)) \(message)"
        }
    }
    
    public func build(logType:LogType, error:Error, fileID: String = #fileID, function: String = #function, line: Int = #line) -> String {
        return "\(LogType.iconOfType(logType)) \(self.prefix(category: category, subCategory: subCategory, fileID: fileID, function: function, line: line)) \(error)"
    }
}
