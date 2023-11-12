//
//  File.swift
//  
//
//  Created by Kelvin Wong on 2023/11/13.
//

import Foundation

public class DirectoryGenerator {
    
    public static let `default` = DirectoryGenerator()
    
    fileprivate init() {}
    
    private var path = ""
    
    public func new() -> Self {
        self.path = ""
        return self
    }
    
    
    public func get() -> String {
        return self.path
    }
    
    public func resolve(_ givenPath:String) -> Self {
        if givenPath.hasPrefix("~/") {
            if #available(macOS 13.0, *) {
                self.path = givenPath.replacingFirstOccurrence(of: "~/", with: Self.defaultUserHomeDirectory().path())
            }else{
                self.path = givenPath.replacingFirstOccurrence(of: "~/", with: Self.defaultUserHomeDirectory().path)
            }
        }else{
            self.path = givenPath
        }
        return self.mkdirs()
    }
    
    public func subfolder(_ text:String) -> Self {
        self.path = "\(self.path.removeLastStash())\(text.withFirstStash().removeLastStash())"
        
        return self.mkdirs()
    }
    
    public func subfolder(dateFormat:String) -> Self {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let datePart = dateFormatter.string(from: Date())
        self.path = "\(self.path.removeLastStash())\(datePart.withFirstStash().removeLastStash())"
        
        return self.mkdirs()
    }
    
    private func mkdirs() -> Self {
        if !self.path.isDirectoryExists() {
            let (created, error) = self.path.mkdirs()
            if !created {
                print("ERROR: Unable to create logging directory - \(String(describing: error))")
            }
        }
        
        return self
    }
    
    public func userHome() -> Self {
        if #available(macOS 13.0, *) {
            self.path = Self.defaultUserHomeDirectory().path()
        }else{
            self.path = Self.defaultUserHomeDirectory().path
        }
        return self
    }
    
    public func userDocuments() -> Self {
        if #available(macOS 13.0, *) {
            self.path = Self.defaultUserDocumentsDirectory().path()
        }else{
            self.path = Self.defaultUserDocumentsDirectory().path
        }
        return self
    }
    
    fileprivate static func defaultUserDocumentsDirectory() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }
    
    fileprivate static func defaultUserHomeDirectory() -> URL {
        return defaultUserDocumentsDirectory().deletingLastPathComponent()
    }
}

extension String {
    
    
    
    func replacingFirstOccurrence(of string: String, with replacement: String) -> String {
        guard let range = self.range(of: string) else { return self }
        return replacingCharacters(in: range, with: replacement)
    }
    
    
    public func substring(from: Int, to: Int) -> String {
        let length = self.lengthOfBytes(using: String.Encoding.unicode)
        if 0 <= from && from < to && to < length && 0 < to {
            let start = self.index(self.startIndex, offsetBy: from)
            let end = self.index(self.startIndex, offsetBy: to)
            let subString = self[start..<end]
            
            return String(subString)
        } else if 0 <= from && from < length && to < 0 {
            let start = self.index(self.startIndex, offsetBy: from)
            let end = self.index(self.endIndex, offsetBy: to)
            let subString = self[start..<end]
            
            return String(subString)
        } else {
            return self
        }
    }
    
    func withLastStash() -> String {
        if !self.hasSuffix("/") {
            return "\(self)/"
        }
        return self
    }
    
    func withFirstStash() -> String {
        if !self.hasPrefix("/") {
            return "/\(self)"
        }
        return self
    }
    
    func removeLastStash() -> String {
        if self.hasSuffix("/") {
            return self.substring(from: 0, to: -1)
        }
        return self
    }
    
    func removeFirstStash() -> String {
        if self.hasPrefix("/") {
            return self.replacingFirstOccurrence(of: "/", with: "")
        }
        return self
    }
}
