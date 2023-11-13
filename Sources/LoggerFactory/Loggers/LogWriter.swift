//
//  LogWriter.swift
//  
//
//  Created by Kelvin Wong on 2023/11/14.
//

import Foundation

public protocol LogWriter {
    func id() -> String
    func write(message: String)
    func path() -> String
    
    func forCategories(_ categories:[String]) -> Self
    func forSubCategories(_ subCategories:[String]) -> Self
    func forKeywords(_ keywords:[String]) -> Self
    func isCategoryAvailable(_ category:String) -> Bool
    func isSubCategoryAvailable(_ subCategory:String) -> Bool
    func isAnyKeywordMatched(_ message:String) -> Bool
}

public class LoggerBase {
    
    fileprivate var categories:[String] = []
    fileprivate var subCategories:[String] = []
    fileprivate var keywords:[String] = []
    
    
}

extension LogWriter where Self: LoggerBase {
    
    public func forCategories(_ categories: [String]) -> Self {
        self.categories = categories
        return self
    }
    
    public func forSubCategories(_ subCategories: [String]) -> Self {
        self.subCategories = subCategories
        return self
    }
    
    public func forKeywords(_ keywords: [String]) -> Self {
        self.keywords = keywords
        return self
    }
    
    public func isCategoryAvailable(_ category:String) -> Bool {
        return self.categories.isEmpty || self.categories.contains(category)
    }
    
    public func isSubCategoryAvailable(_ subCategory:String) -> Bool {
        return self.subCategories.isEmpty || self.subCategories.contains(subCategory)
    }
    
    public func isAnyKeywordMatched(_ message:String) -> Bool {
        if self.keywords.isEmpty {
            return true
        }else{
            for k in self.keywords {
                if message.contains(k) {
                    return true
                }
            }
            return false
        }
    }
    
}
