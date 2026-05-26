//
//  File.swift
//  
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation

extension String {
    
    func isDirectoryExists() -> Bool {
        var isDir:ObjCBool = false
        if FileManager.default.fileExists(atPath: self, isDirectory: &isDir) {
            if isDir.boolValue == true {
                return true
            }
        }
        return false
    }
    
    func isFileExists() -> Bool {
        if FileManager.default.fileExists(atPath: self) {
            return true
        }
        return false
    }
    
    func sizeOfFile() -> Int64? {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: self) else {
            return nil
        }

        return attrs[.size] as? Int64
    }
    
    func mkdirs(logger:Logger? = nil) -> (Bool, Error?) {
        do {
            try FileManager.default.createDirectory(atPath: self, withIntermediateDirectories: true, attributes: nil)
        }catch{
            if let logger = logger {
                logger.log(.error, error)
            }
            return (false, error)
        }
        return (true, nil)
    }
    
    func appendLineToURL(fileURL: URL) throws {
         try (self + "\n").appendToURL(fileURL: fileURL)
    }

    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
    
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}

extension Date {
    
    func string(format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension Int64 {
    
    func humanReadable(_ unit:ByteCountFormatter.Units) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [unit]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: self)
    }
    
    func humanReadableValue(_ unit:ByteCountFormatter.Units) -> Int {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [unit]
        bcf.countStyle = .binary
        bcf.includesUnit = false
        return Int(bcf.string(fromByteCount: self).replacingOccurrences(of: ",", with: "")) ?? 0
    }
}
