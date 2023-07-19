//
//  File.swift
//  
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation

class ConsoleLogger : LogWriter {
    
    func write(message: String) {
        print(message)
    }
    
}
