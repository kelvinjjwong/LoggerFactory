//
//  ConsoleLogger.swift
//  
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation

public class ConsoleLogger : LoggerBase, LogWriter {
    
    private var _id = "console"
    
    public func id() -> String {
        return self._id
    }
    
    public override init() {
        super.init()
    }
    
    public func write(message: String) {
        print(message)
    }
    
}
