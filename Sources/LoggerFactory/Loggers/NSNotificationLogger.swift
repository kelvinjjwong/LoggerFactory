//
//  NotifyLogger.swift
//  
//
//  Created by kelvinwong on 2023/11/14.
//

import Foundation

public class NSNotificationLogger : LoggerBase, LogWriter {
    
    public static func id() -> String {
        return "notification"
    }
    
    public func id() -> String {
        return "notification"
    }
    
    private var key = ""
    
    public init(key:String) {
        super.init()
        self.key = key
    }
    
    public func write(message: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.key), object: message)
    }
    
}
