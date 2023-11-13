//
//  FileLogger.swift
//  
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation

public class FileLogger : LoggerBase, LogWriter {
    
    
    public static func id() -> String {
        return "file"
    }
    
    public func id() -> String {
        return "file"
    }
    
    public func path() -> String {
        if #available(macOS 13.0, *) {
            return self.logFileUrl.path()
        }else {
            return self.logFileUrl.path
        }
    }
    
    
    fileprivate var logFileUrl:URL
    
    public init(pathOfFolder:String = Defaults.defaultLoggingDirectory(), filename:String = Defaults.defaultLoggingFilename()) {
        let pathOfFolder = DirectoryGenerator.default.resolve(pathOfFolder).get()
        if #available(macOS 13.0, *) {
            self.logFileUrl = URL(fileURLWithPath: pathOfFolder).appending(path: filename)
        }else{
            self.logFileUrl = URL(fileURLWithPath: pathOfFolder).appendingPathComponent(filename)
        }
        print("Writing log to file: \(logFileUrl.path)")
        super.init()
        self.write(message: "\(ISO8601DateFormatter().string(from: Date())) logger initialized.")
    }
    
    public convenience init(pathOfFolder:String) {
        self.init(pathOfFolder: pathOfFolder, filename: Defaults.defaultLoggingFilename())
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
