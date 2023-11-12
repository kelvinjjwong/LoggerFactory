//
//  File.swift
//  
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation

public class FileLogger : LogWriter {
    
    public static func id() -> String {
        return "file"
    }
    
    public func id() -> String {
        return "file"
    }
    
    
    fileprivate var logFileUrl:URL
    
    public init(pathOfFolder:String, filename:String) {
        if #available(macOS 13.0, *) {
            var pathOfFolder = pathOfFolder
            if pathOfFolder.hasPrefix("~/") {
                pathOfFolder = pathOfFolder.replacingOccurrences(of: "~/", with: FileLogger.defaultUserHomeDirectory().path())
            }
            self.logFileUrl = URL(fileURLWithPath: pathOfFolder).appending(path: filename)
        }else{
            var pathOfFolder = pathOfFolder
            if pathOfFolder.hasPrefix("~/") {
                pathOfFolder = pathOfFolder.replacingOccurrences(of: "~/", with: FileLogger.defaultUserHomeDirectory().path)
            }
            self.logFileUrl = URL(fileURLWithPath: pathOfFolder).appendingPathComponent(filename)
        }
        print("Writing log to file: \(logFileUrl.path)")
        self.write(message: "Writing log to file: \(logFileUrl.path)")
    }
    
    public convenience init() {
        if #available(macOS 13.0, *) {
            self.init(pathOfFolder: Self.defaultLoggingDirectory().path(), filename: Self.defaultLoggingFilename())
        } else {
            // Fallback on earlier versions
            self.init(pathOfFolder: Self.defaultLoggingDirectory().path, filename: Self.defaultLoggingFilename())
        }
    }
    
    public convenience init(pathOfFolder:String) {
        self.init(pathOfFolder: pathOfFolder, filename: Self.defaultLoggingFilename())
    }
    
    fileprivate static func defaultLoggingFilename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmm"
        let datePart = dateFormatter.string(from: Date())
        return "\(datePart).log"
    }
    
    fileprivate static func defaultUserDocumentsDirectory() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }
    
    fileprivate static func defaultUserHomeDirectory() -> URL {
        return defaultUserDocumentsDirectory().deletingLastPathComponent()
    }
    
    fileprivate static func defaultLoggingDirectory() -> URL {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.apple.toolsQA.CocoaApp_CD" in the user's Application Support directory.
        let appSupportURL = defaultUserDocumentsDirectory()
        let url = appSupportURL.appendingPathComponent("log")
        
        if !url.path.isDirectoryExists() {
            let (created, error) = url.path.mkdirs()
            if !created {
                print("ERROR: Unable to create logging directory - \(String(describing: error))")
            }
        }
        
        return url
    }
    
    public func write(message:String) {
        DispatchQueue.global().async {
            
            do {
                try message.appendLineToURL(fileURL: self.logFileUrl)
            }catch {
                let msg = "\(LogType.iconOfType(LogType.error)) Unable to write log to file \(self.logFileUrl.path) - \(error)"
                print(msg)
            }
        }
    }
}
