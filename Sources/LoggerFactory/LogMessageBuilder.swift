//
//  File.swift
//  
//
//  Created by kelvinwong on 2023/7/19.
//


import Foundation

protocol LogMessageBuilderInterface {
    func build(logType:LogType, message:String, error:Error?) -> String
    func build(logType:LogType, message:Int, error:Error?) -> String
    func build(logType:LogType, message:Double, error:Error?) -> String
    func build(logType:LogType, message:Float, error:Error?) -> String
    func build(logType:LogType, message:Any, error:Error?) -> String
    func build(logType:LogType, error:Error) -> String
}

public class LogMessageBuilder : LogMessageBuilderInterface {
    
    private let dtFormatter = ISO8601DateFormatter()
    
    private var category:String = ""
    private var subCategory:String = ""
    
    public init(category:String, subCategory:String) {
        self.category = category
        self.subCategory = subCategory
    }
    
    fileprivate func prefix(category:String, subCategory:String) -> String {
        if subCategory == "" {
            return "\(self.dtFormatter.string(from: Date())) [\(category)]"
        }else{
            return "\(self.dtFormatter.string(from: Date())) [\(category)][\(subCategory)]"
        }
    }
    
    public func build(logType:LogType, message:String, error:Error?) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.error)) \(self.prefix(category: category, subCategory: subCategory)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(logType)) \(self.prefix(category: category, subCategory: subCategory)) \(message)"
        }
    }
    
    public func build(logType:LogType, message:Int, error:Error?) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.error)) \(self.prefix(category: category, subCategory: subCategory)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(logType)) \(self.prefix(category: category, subCategory: subCategory)) \(message)"
        }
    }
    
    public func build(logType:LogType, message:Double, error:Error?) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.error)) \(self.prefix(category: category, subCategory: subCategory)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(logType)) \(self.prefix(category: category, subCategory: subCategory)) \(message)"
        }
    }
    
    public func build(logType:LogType, message:Float, error:Error?) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.error)) \(self.prefix(category: category, subCategory: subCategory)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(logType)) \(self.prefix(category: category, subCategory: subCategory)) \(message)"
        }
    }
    
    public func build(logType:LogType, message:Any, error:Error?) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.error)) \(self.prefix(category: category, subCategory: subCategory)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(logType)) \(self.prefix(category: category, subCategory: subCategory)) \(message)"
        }
    }
    
    public func build(logType:LogType, error:Error) -> String {
        return "\(LogType.iconOfType(logType)) \(self.prefix(category: category, subCategory: subCategory)) \(error)"
    }
}
