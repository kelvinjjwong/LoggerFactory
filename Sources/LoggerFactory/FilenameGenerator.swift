//
//  File.swift
//  
//
//  Created by Kelvin Wong on 2023/11/13.
//

import Foundation

public class FilenameGenerator {
    
    public static let `default` = FilenameGenerator()
    
    fileprivate init() {}
    
    private var filename = ""
    
    public func new() -> Self {
        self.filename = ""
        return self
    }
    
    public func append(text:String) -> Self {
        self.filename = "\(self.filename)\(text)"
        return self
    }
    
    public func date(format:String) -> Self {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let datePart = dateFormatter.string(from: Date())
        self.filename = "\(filename)\(datePart)"
        return self
    }
    
    public func get() -> String {
        return self.filename
    }
}
