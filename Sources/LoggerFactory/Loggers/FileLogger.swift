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
    
    public func file() -> String {
        if #available(macOS 13.0, *) {
            return self.logFileUrl.path()
        }else {
            return self.logFileUrl.path
        }
    }
    
    fileprivate var pathOfFolder = ""
    fileprivate var filename = ""
    fileprivate var logFileUrl:URL
    fileprivate var rollPolicy:FileRollPolicy
    
    public init(pathOfFolder:String = Defaults.defaultLoggingDirectory(), filename:String = Defaults.defaultLoggingFilename()) {
        let pathOfFolder = DirectoryGenerator.default.resolve(pathOfFolder).get()
        self.pathOfFolder = pathOfFolder
        self.filename = filename
        if #available(macOS 13.0, *) {
            self.logFileUrl = URL(fileURLWithPath: pathOfFolder).appending(path: filename)
        }else{
            self.logFileUrl = URL(fileURLWithPath: pathOfFolder).appendingPathComponent(filename)
        }
        self.rollPolicy = FileRollPolicy.empty()
        super.init()
        self.write(message: "\(ISO8601DateFormatter().string(from: Date())) logger initialized.")
        print("\(LogType.iconOfType(LogType.info)) \(ISO8601DateFormatter().string(from: Date())) [FileLogge] Writing log to file: \(logFileUrl.path)")
    }
    
    public func roll(atSize: Int = 0, unit: ByteCountFormatter.Units = .useBytes, atHour: Int = -1, atMinute:Int = -1, everyDay:Bool = false, everyHour:Bool = false, everyMinute:Bool = false) -> Self {
        self.rollPolicy = FileRollPolicy(atSize: atSize, unit: unit, atHour: atHour, atMinute: atMinute, everyDay: everyDay, everyHour: everyHour, everyMinute: everyMinute)
        if self.rollPolicy.isAvailable() {
            self.startMonitoring()
        }
        return self
    }
    
    public func write(message:String) {
        DispatchQueue.global().async {
            
            do {
                try message.appendLineToURL(fileURL: self.logFileUrl)
            }catch {
                let msg = "\(LogType.iconOfType(LogType.error)) \(ISO8601DateFormatter().string(from: Date())) Unable to write log to file \(self.logFileUrl.path) - \(error)"
                print(msg)
            }
        }
    }
    
    fileprivate var suspendedMonitoring = false
    fileprivate var startedMonitoring = false
    
    fileprivate var lastTimeTag = ""
    fileprivate var lastHandleHour = -1
    fileprivate var lastHandleMinute = -1
    fileprivate let timeTagFormat = "yyyyMMdd.HHmm"
    
    private func startMonitoring() {
        guard !self.startedMonitoring else {return}
        
        if self.rollPolicy.isAvailable() {
            self.startedMonitoring = true
            
            let now = Date()
            self.lastTimeTag = now.string(format: self.timeTagFormat)
            self.lastHandleHour = Calendar.current.component(.hour, from: now)
            self.lastHandleMinute = Calendar.current.component(.minute, from: now)
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
                if !self.suspendedMonitoring {
                    var shouldRoll = false
                    if self.rollPolicy.atSize() > 0 {
                        if let size = self.file().sizeOfFile(), size.humanReadableValue(self.rollPolicy.sizeUnit()) >= self.rollPolicy.atSize() {
                            shouldRoll = true
                        }
                    }else {
                        let now = Date()
                        let hour = Calendar.current.component(.hour, from: now)
                        let minute = Calendar.current.component(.minute, from: now)
                        
                        if self.rollPolicy.everyHour() {
                            if self.rollPolicy.everyMinute() {
                                if self.lastHandleMinute != minute {
                                    shouldRoll = true
                                    self.lastHandleHour = hour
                                    self.lastHandleMinute = minute
                                }
                            }else if self.rollPolicy.atMinute() == minute {
                                if self.lastHandleMinute != minute {
                                    shouldRoll = true
                                    self.lastHandleHour = hour
                                    self.lastHandleMinute = minute
                                }
                            }
                        }else if self.rollPolicy.atHour() == hour {
                            if self.rollPolicy.everyMinute() {
                                if self.lastHandleMinute != minute {
                                    shouldRoll = true
                                    self.lastHandleHour = hour
                                    self.lastHandleMinute = minute
                                }
                            }else if self.rollPolicy.atMinute() == minute {
                                if self.lastHandleMinute != minute {
                                    shouldRoll = true
                                    self.lastHandleHour = hour
                                    self.lastHandleMinute = minute
                                }
                            }
                        }
                    }
                    if shouldRoll {
                        self.suspendedMonitoring = true
                        var tags:[FileRollTag] = []
                        if self.rollPolicy.atSize() > 0 {
                            tags.append(.sequence)
                        }
                        if self.rollPolicy.everyDay() || self.rollPolicy.everyHour() || self.rollPolicy.everyMinute() || self.rollPolicy.atHour() >= 0 || self.rollPolicy.atMinute() >= 0 {
                            tags.append(.date)
                        }
                        self.rollFile(tags: tags)
                        self.suspendedMonitoring = false
                    }
                }
            }
        }
    }
    
    private func generateArchiveFilename(tags:[FileRollTag]) -> String {
        var majorPartOfFilename = self.filename.substring(from: 0, to: self.filename.count-4)
        
        if tags.contains(.date) {
            let prevTimeTag = self.lastTimeTag
            
            // generate next time tag
            let now = Date()
            var requireHour = 0
            var requireMinute = 0
            if self.rollPolicy.everyDay() { // 20231114.0000
                requireHour = 0
                requireMinute = 0
            }
            if self.rollPolicy.everyMinute() || self.rollPolicy.atMinute() >= 0 { // 20231114.0022
                requireMinute = Calendar.current.component(.minute, from: now)
            }
            if self.rollPolicy.everyHour() || self.rollPolicy.atHour() >= 0 { // 20231114.1100 or 20231114.1122
                requireHour = Calendar.current.component(.hour, from: now)
            }
            
            let date = Calendar.current.date(bySettingHour: requireHour, minute: requireMinute, second: 0, of: Date())!
            
            let nextTimeTag = date.string(format: self.timeTagFormat)
            majorPartOfFilename = "\(majorPartOfFilename).from_\(prevTimeTag)_to_\(nextTimeTag)"
            self.lastTimeTag = nextTimeTag
        }
        
        if tags.contains(.sequence) {
            var existArchives = -1
            do {
                let items = try FileManager.default.contentsOfDirectory(atPath: self.pathOfFolder)
                for item in items {
                    if item.contains(majorPartOfFilename) && item.hasSuffix(".log") {
                        existArchives += 1
                    }
                }
            }catch{
                let msg = "\(LogType.iconOfType(LogType.error)) \(ISO8601DateFormatter().string(from: Date())) [FileLogger][roll] Unable to list log files in \(self.pathOfFolder) - \(error)"
                self.write(message: msg)
                print(msg)
                return ""
            }
            return "\(majorPartOfFilename).\(existArchives+1).log"
        }
        
        if tags.contains(.date) {
            return "\(majorPartOfFilename).log"
        }else{
            return "\(majorPartOfFilename).rolled.log"
        }
    }
    
    private func rollFile(tags:[FileRollTag]) {
        let archiveFilename = self.generateArchiveFilename(tags: tags)
        guard archiveFilename != "" else {return}
        
        var fromPath = ""
        var toPath = ""
        do {
            
            if #available(macOS 13.0, *) {
                fromPath = self.logFileUrl.path()
                toPath = URL(fileURLWithPath: pathOfFolder).appending(path: archiveFilename).path()
            }else{
                fromPath = self.logFileUrl.path
                toPath = URL(fileURLWithPath: pathOfFolder).appendingPathComponent(archiveFilename).path
            }
            
            try FileManager.default.moveItem(atPath: fromPath, toPath: toPath)
            try "\(ISO8601DateFormatter().string(from: Date())) continue from previous file \(archiveFilename).\n".write(to: self.logFileUrl, atomically: false, encoding: .utf8)
        }catch{
            
            let msg = "\(LogType.iconOfType(LogType.error)) \(ISO8601DateFormatter().string(from: Date())) [FileLogger][roll] Unable to archive log file \(fromPath) - \(error)"
            self.write(message: msg)
            print(msg)
            return
        }
    }
}
