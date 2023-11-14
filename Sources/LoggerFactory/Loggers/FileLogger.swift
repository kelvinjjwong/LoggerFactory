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
        print("\(LogType.iconOfType(LogType.info)) \(ISO8601DateFormatter().string(from: Date())) Writing log to file: \(logFileUrl.path)")
    }
    
    public func roll(atSize: Int = 0, unit: ByteCountFormatter.Units = .useBytes, byDate: Bool = false, atHour: Int = 0) -> Self {
        self.rollPolicy = FileRollPolicy(atSize: atSize, unit: unit, byDate: byDate, atHour: atHour)
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
    
    public func startMonitoring() {
        guard !self.startedMonitoring else {return}
        
        if self.rollPolicy.isAvailable() {
            self.startedMonitoring = true
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
                if !self.suspendedMonitoring {
                    var shouldRoll = false
                    if self.rollPolicy.atSize() > 0 {
                        if let size = self.file().sizeOfFile(), size.humanReadableValue(self.rollPolicy.sizeUnit()) >= self.rollPolicy.atSize() {
                            shouldRoll = true
                        }
                    }
                    if shouldRoll {
                        self.suspendedMonitoring = true
                        self.rollFile()
                        self.suspendedMonitoring = false
                    }
                }
            }
        }
    }
    
    public func rollFile() {
        let majorPartOfFilename = self.filename.substring(from: 0, to: self.filename.count-4)
        var existArchives = -1
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: self.pathOfFolder)
            for item in items {
                if item.contains(majorPartOfFilename) && item.hasSuffix(".log") {
                    existArchives += 1
                }
            }
        }catch{
            let msg = "\(LogType.iconOfType(LogType.error)) \(ISO8601DateFormatter().string(from: Date())) Unable to list log files in \(self.pathOfFolder) - \(error)"
            print(msg)
            return
        }
        var fromPath = ""
        var toPath = ""
        let archiveFilename = "\(majorPartOfFilename).\(existArchives+1).log"
        do {
            
            if #available(macOS 13.0, *) {
                fromPath = self.logFileUrl.path()
                toPath = URL(fileURLWithPath: pathOfFolder).appending(path: archiveFilename).path()
            }else{
                fromPath = self.logFileUrl.path
                toPath = URL(fileURLWithPath: pathOfFolder).appendingPathComponent(archiveFilename).path
            }
            
            try FileManager.default.moveItem(atPath: fromPath, toPath: toPath)
            try "\(ISO8601DateFormatter().string(from: Date())) rolled to \(archiveFilename).\n".write(to: self.logFileUrl, atomically: false, encoding: .utf8)
        }catch{
            
            let msg = "\(LogType.iconOfType(LogType.error)) \(ISO8601DateFormatter().string(from: Date())) Unable to archive log file \(fromPath) - \(error)"
            print(msg)
            return
        }
    }
}

public class FileRollPolicy {
    
    private var rollAtSize: Int = 0
    private var rollAtSizeUnit: ByteCountFormatter.Units = .useBytes
    private var rollByDate: Bool = false
    private var rollAtHour: Int = 0
    
    public init(atSize: Int = 0, unit: ByteCountFormatter.Units = .useBytes, byDate: Bool = false, atHour: Int = 0) {
        self.rollAtSize = atSize
        self.rollAtSizeUnit = unit
        self.rollByDate = byDate
        self.rollAtHour = atHour
    }
    
    public func isAvailable() -> Bool {
        return self.rollAtSize > 0
        || (self.rollByDate
            && (self.rollAtHour >= 0 && self.rollAtHour <= 24)
        )
    }
    
    public func atSize() -> Int {
        return self.rollAtSize
    }
    
    public func sizeUnit() -> ByteCountFormatter.Units {
        return self.rollAtSizeUnit
    }
    
    public func byDate() -> Bool {
        return self.rollByDate
    }
    
    public func atHour() -> Int {
        return self.rollAtHour
    }
}
