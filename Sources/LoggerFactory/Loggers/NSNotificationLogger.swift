//
//  NotifyLogger.swift
//  
//
//  Created by kelvinwong on 2023/11/14.
//

import Foundation

public class NSNotificationLogger : LoggerBase, LogWriter {
    
    private var _id = "notification"
    
    public func id() -> String {
        return self._id
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
