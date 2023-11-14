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
    
    public init(pathOfFolder:String = Defaults.defaultLoggingDirectory(), filename:String = Defaults.defaultLoggingFilename(), roll:FileRollPolicy = FileRollPolicy()) {
        self.rollPolicy = roll
        let pathOfFolder = DirectoryGenerator.default.resolve(pathOfFolder).get()
        self.pathOfFolder = pathOfFolder
        self.filename = filename
        if #available(macOS 13.0, *) {
            self.logFileUrl = URL(fileURLWithPath: pathOfFolder).appending(path: filename)
        }else{
            self.logFileUrl = URL(fileURLWithPath: pathOfFolder).appendingPathComponent(filename)
        }
        super.init()
        self.write(message: "\(ISO8601DateFormatter().string(from: Date())) logger initialized.")
        if self.rollPolicy.isAvailable() {
            self.startMonitoring()
        }
        print("\(LogType.iconOfType(LogType.info)) \(ISO8601DateFormatter().string(from: Date())) [FileLogge] Writing log to file: \(logFileUrl.path)")
    }
    
    public func roll(atSize: Int = 0, unit: ByteCountFormatter.Units = .useBytes, atHour: Int = 0, atMinute:Int = 0, everyHour:Bool = false, everyMinute:Bool = false) -> Self {
        self.rollPolicy = FileRollPolicy(atSize: atSize, unit: unit, atHour: atHour, atMinute: atMinute, everyHour: everyHour, everyMinute: everyMinute)
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
    
    public func startMonitoring() {
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
                        self.rollFile(tag: self.rollPolicy.atSize() > 0 ? .sequence : .date)
                        self.suspendedMonitoring = false
                    }
                }
            }
        }
    }
    
    private func generateArchiveFilename(tag:FileRollTag = .sequence) -> String {
        let majorPartOfFilename = self.filename.substring(from: 0, to: self.filename.count-4)
        if tag == .sequence {
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
        }else if tag == .date {
            let prevTimeTag = self.lastTimeTag
            let nextTimeTag = Date().string(format: self.timeTagFormat)
            let filename = "\(majorPartOfFilename).from_\(prevTimeTag)_to_\(nextTimeTag).log"
            self.lastTimeTag = nextTimeTag
            return filename
        }else{
            return "\(majorPartOfFilename).rolled.log"
        }
    }
    
    public func rollFile(tag:FileRollTag = .sequence) {
        let archiveFilename = self.generateArchiveFilename(tag: tag)
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

public enum FileRollTag {
    case sequence
    case date
}

public class FileRollPolicy {
    
    private var rollAtSize: Int = 0
    private var rollAtSizeUnit: ByteCountFormatter.Units = .useBytes
    private var rollAtHour: Int = 0
    private var rollAtMinute: Int = 0
    private var rollEveryHour: Bool = false
    private var rollEveryMinute: Bool = false
    
    public init(atSize: Int = 0, unit: ByteCountFormatter.Units = .useBytes, atHour: Int = -1, atMinute:Int = 0, everyHour:Bool = false, everyMinute:Bool = false) {
        self.rollAtSize = atSize
        self.rollAtSizeUnit = unit
        self.rollAtHour = atHour
        self.rollAtMinute = atMinute
        self.rollEveryHour = everyHour
        self.rollEveryMinute = everyMinute
    }
    
    public func isAvailable() -> Bool {
        return self.rollAtSize > 0
        || (
            (self.rollAtHour >= 0 && self.rollAtHour <= 24)
            || (self.rollAtMinute >= 0 && self.rollAtMinute <= 59)
            
        )
    }
    
    public func atSize() -> Int {
        return self.rollAtSize
    }
    
    public func sizeUnit() -> ByteCountFormatter.Units {
        return self.rollAtSizeUnit
    }
    
    public func atHour() -> Int {
        return self.rollAtHour
    }
    
    public func atMinute() -> Int {
        return self.rollAtMinute
    }
    
    public func everyHour() -> Bool {
        return self.rollEveryHour
    }
    
    public func everyMinute() -> Bool {
        return self.rollEveryMinute
    }
}
