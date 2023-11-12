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
        let pathOfFolder = DirectoryGenerator.default.resolve(pathOfFolder).get()
        if #available(macOS 13.0, *) {
            self.logFileUrl = URL(fileURLWithPath: pathOfFolder).appending(path: filename)
        }else{
            self.logFileUrl = URL(fileURLWithPath: pathOfFolder).appendingPathComponent(filename)
        }
        print("Writing log to file: \(logFileUrl.path)")
        self.write(message: "Writing log to file: \(logFileUrl.path)")
    }
    
    public convenience init() {
        self.init(pathOfFolder: Self.defaultLoggingDirectory(), filename: Self.defaultLoggingFilename())
    }
    
    public convenience init(pathOfFolder:String) {
        self.init(pathOfFolder: pathOfFolder, filename: Self.defaultLoggingFilename())
    }
    
    fileprivate static func defaultLoggingFilename() -> String {
        return FilenameGenerator.default.new().date(format: "yyyy-MM-dd_HHmm").append(text: ".log").get()
    }
    
    fileprivate static func defaultLoggingDirectory() -> String {
        return DirectoryGenerator.default.new().userDocuments().subfolder("log").get()
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
