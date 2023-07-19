//
//  File.swift
//  
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation

public class ConsoleLogger : LogWriter {
    
    public func write(message: String) {
        print(message)
    }
    
}
