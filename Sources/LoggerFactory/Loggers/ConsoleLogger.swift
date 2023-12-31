//
//  ConsoleLogger.swift
//  
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation

public class ConsoleLogger : LoggerBase, LogWriter {
    
    public static func id() -> String {
        return "console"
    }
    
    public func id() -> String {
        return "console"
    }
    
    public override init() {
        super.init()
    }
    
    public func write(message: String) {
        print(message)
    }
    
}
