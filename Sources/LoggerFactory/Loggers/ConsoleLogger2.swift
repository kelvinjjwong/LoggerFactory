//
//  ConsoleLogger.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2026/3/28.
//  Copyright © 2026 nonamecat. All rights reserved.
//

import Foundation

public class ConsoleLogger2 : LogWriter2 {
    
    public static let `default` = ConsoleLogger2()
    
    private var _forCategory = ""
    private var _forSubCategory = ""
    private var _forLogType:[LogType] = []
    
    public init(forCategory:String = "", forSubCategory:String = "", forLogType:[LogType] = []) {
        self._forCategory = forCategory
        self._forSubCategory = forSubCategory
        self._forLogType = forLogType
    }
    
    private let _id = "console"
    
    public func id() -> String {
        return self._id
    }
    
    public func file() -> String {
        return "console"
    }
    
    public func write(message: String) {
        print(message)
    }
    
    public func getForLogType() -> [LogType] {
        return self._forLogType
    }
    
    public func getForCategory() -> String {
        return self._forCategory
    }
    
    public func getForSubCategory() -> String {
        return self._forSubCategory
    }
    
    public func log(_ message:String, fileID: String = #fileID, function: String = #function, line: Int = #line) {
        print("📝 \(LoggerSetting2.dateTimeFormat().string(from: Date())) [\(fileID.replacingOccurrences(of: ".swift", with: "", options: .backwards))#\(function):\(line)] \(message)")
    }
    
    public func error(_ message:String, fileID: String = #fileID, function: String = #function, line: Int = #line) {
        print("🧨 \(LoggerSetting2.dateTimeFormat().string(from: Date())) \(fileID.replacingOccurrences(of: ".swift", with: "", options: .backwards))#\(function):\(line)] \(message)")
    }
}
