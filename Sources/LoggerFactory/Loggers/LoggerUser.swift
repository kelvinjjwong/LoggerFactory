//
//  File.swift
//  
//
//  Created by kelvinwong on 2023/11/12.
//

import Foundation


public protocol LoggerUser {
    
    func loggingCategory(category: String, subCategory: String) -> Self
    func loggingDestinations(_ destinations:[String]) -> Self
    func excludeLoggingLevels(_ levels:[LogType]) -> Self
    func includeLoggingLevels(_ levels:[LogType]) -> Self
}
