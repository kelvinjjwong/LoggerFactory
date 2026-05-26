//
//  File.swift
//  
//
//  Created by kelvinwong on 2023/11/12.
//

import Foundation

public protocol LoggerRegister {
    func registerWriter(id: String, writer:LogWriter) -> Self 
    func addDestination(_ destination:String) -> Self
    func removeDestination(_ destination:String) -> Self
}
