//
//  LoggerProfile.swift
//  LoggerFactory
//
//  Created by Kelvin Wong on 2026/5/24.
//

import Foundation

public class LoggerProfile : Codable {
    
    public var logtype = ""
    public var category = ""
    public var subCategory = ""
    public var writerId = ""
    
    public func id() -> String {
        return "\(logtype):\(category):\(subCategory):\(writerId)"
    }
    
    public func toJSON() -> String {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            return json ?? "{}"
        }catch{
            return "{}"
        }
    }
    
    public static func fromJSON(_ jsonString:String) -> LoggerProfile? {
        let jsonDecoder = JSONDecoder()
        do{
            return try jsonDecoder.decode(LoggerProfile.self, from: jsonString.data(using: .utf8)!)
        }catch{
            return nil
        }
    }
}
