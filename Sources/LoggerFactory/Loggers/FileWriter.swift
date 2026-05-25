//
//  FileWriter.swift
//  LoggerFactory
//
//  Created by Kelvin Wong on 2026/5/26.
//

import Foundation

actor FileWriter {
    let fileURL: URL
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    // This method is isolated to the actor, ensuring writes happen sequentially
    func writeLine(_ line: String) throws {
        guard let data = (line + "\n").data(using: .utf8) else { return }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            // Append data to the existing file
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            defer { try? fileHandle.close() }
            
            if #available(macOS 10.15, iOS 13.0, *) {
                try fileHandle.seekToEnd()
                try fileHandle.write(contentsOf: data)
            } else {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
            }
        } else {
            // Create a new file and write the first line
            try data.write(to: fileURL, options: .atomic)
        }
    }
}
