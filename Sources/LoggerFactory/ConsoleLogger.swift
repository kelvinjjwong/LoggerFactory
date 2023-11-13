//
//  File.swift
//  
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation

public class ConsoleLogger : LogWriter {
    
    public static func id() -> String {
        return "console"
    }
    
    public func id() -> String {
        return "console"
    }
    
    public func path() -> String {
        return "console"
    }
    
    
    public init() {
        
    }
    
    public func write(message: String) {
        print(message)
    }
    
    private var categories:[String] = []
    private var subCategories:[String] = []
    private var keywords:[String] = []
    
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
