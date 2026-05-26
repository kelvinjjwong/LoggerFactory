//
//  FileLogger.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2026/3/28.
//  Copyright © 2026 nonamecat. All rights reserved.
//

import Foundation

public class FileLogger2 : LogWriter2, Codable {
    
    private var _id = ""
    private var _folder = ""
    private var _filename = ""
    
    private var _forCategory = ""
    private var _forSubCategory = ""
    private var _forLogType:[LogType] = []
    
    fileprivate var logFileUrl:URL
//    fileprivate var rollPolicy:FileRollPolicy
    
    public init(id:String, folder:String, filename:String, forCategory:String = "", forSubCategory:String = "", forLogType:[LogType] = []) {
        self._id = id
        self._folder = folder
        self._filename = filename
        
        self._forCategory = forCategory
        self._forSubCategory = forSubCategory
        self._forLogType = forLogType
        
        self.logFileUrl = URL(fileURLWithPath: self._folder).appending(path: "\(self._filename).log")
//        self.rollPolicy = FileRollPolicy.empty()
    }
    
    public func getForLogType() -> [LogType] {
        return self._forLogType
    }
    
    public func getForCategory() -> String {
        return self._forCategory
    }
    
    public func getForSubCategory() -> String {
        return self._forSubCategory
    }
    
    public func id() -> String {
        return self._id
    }
    
    public func file() -> String {
        return URL(fileURLWithPath: self._folder).appending(path: self._filename).path()
    }
    
    public func write(message: String) async {
        do {
            // All 100 tasks try to write concurrently
            
            let fileWriter = FileWriter(fileURL: self.logFileUrl)
            try await fileWriter.writeLine(message)
        } catch {
            let msg = "[\(self._id)] Unable to write log to file \(self.logFileUrl.path) - \(error)"
            ConsoleLogger2.default.error(msg)
        }
    }
    
    
    public func roll(atSize: Int = 0, unit: ByteCountFormatter.Units = .useBytes, atHour: Int = -1, atMinute:Int = -1, everyDay:Bool = false, everyHour:Bool = false, everyMinute:Bool = false) -> Self {
//        self.rollPolicy = FileRollPolicy(atSize: atSize, unit: unit, atHour: atHour, atMinute: atMinute, everyDay: everyDay, everyHour: everyHour, everyMinute: everyMinute)
//        if self.rollPolicy.isAvailable() {
//            self.startMonitoring()
//        }
        return self
    }
    
    public func isMatched(category:String, subCategory:String, logType:[LogType]) -> Bool {
        if self._forCategory == "" {
            if !Set(self._forLogType).intersection(Set(logType)).isEmpty {
                return true
            }else{
                return false
            }
        }else{
            if self._forCategory == category {
                if self._forSubCategory == "" {
                    if !Set(self._forLogType).intersection(Set(logType)).isEmpty {
                        return true
                    }else{
                        return false
                    }
                }else{
                    if self._forSubCategory == subCategory {
                        if !Set(self._forLogType).intersection(Set(logType)).isEmpty {
                            return true
                        }else{
                            return false
                        }
                    }else{
                        return false
                    }
                }
            }else{
                return false
            }
        }
    }
    
    public func toJSON() -> String {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            return json ?? "{}"
        }catch{
            ConsoleLogger2.default.error("\(error)")
            return "{}"
        }
    }
    
    
    
    fileprivate var suspendedMonitoring = false
    fileprivate var startedMonitoring = false
    
    fileprivate var lastTimeTag = ""
    fileprivate var lastHandleHour = -1
    fileprivate var lastHandleMinute = -1
    fileprivate let timeTagFormat = "yyyyMMdd.HHmm"
    
//    private func startMonitoring() {
//        guard !self.startedMonitoring else {return}
//        
//        if self.rollPolicy.isAvailable() {
//            self.startedMonitoring = true
//            
//            let now = Date()
//            self.lastTimeTag = now.string(format: self.timeTagFormat)
//            self.lastHandleHour = Calendar.current.component(.hour, from: now)
//            self.lastHandleMinute = Calendar.current.component(.minute, from: now)
//            
//            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
//                if !self.suspendedMonitoring {
//                    var shouldRoll = false
//                    if self.rollPolicy.atSize() > 0 {
//                        if let size = self.file().sizeOfFile(), size.humanReadableValue(self.rollPolicy.sizeUnit()) >= self.rollPolicy.atSize() {
//                            shouldRoll = true
//                        }
//                    }else {
//                        let now = Date()
//                        let hour = Calendar.current.component(.hour, from: now)
//                        let minute = Calendar.current.component(.minute, from: now)
//                        
//                        if self.rollPolicy.everyHour() {
//                            if self.rollPolicy.everyMinute() {
//                                if self.lastHandleMinute != minute {
//                                    shouldRoll = true
//                                    self.lastHandleHour = hour
//                                    self.lastHandleMinute = minute
//                                }
//                            }else if self.rollPolicy.atMinute() == minute {
//                                if self.lastHandleMinute != minute {
//                                    shouldRoll = true
//                                    self.lastHandleHour = hour
//                                    self.lastHandleMinute = minute
//                                }
//                            }
//                        }else if self.rollPolicy.atHour() == hour {
//                            if self.rollPolicy.everyMinute() {
//                                if self.lastHandleMinute != minute {
//                                    shouldRoll = true
//                                    self.lastHandleHour = hour
//                                    self.lastHandleMinute = minute
//                                }
//                            }else if self.rollPolicy.atMinute() == minute {
//                                if self.lastHandleMinute != minute {
//                                    shouldRoll = true
//                                    self.lastHandleHour = hour
//                                    self.lastHandleMinute = minute
//                                }
//                            }
//                        }
//                    }
//                    if shouldRoll {
//                        self.suspendedMonitoring = true
//                        var tags:[FileRollTag] = []
//                        if self.rollPolicy.atSize() > 0 {
//                            tags.append(.sequence)
//                        }
//                        if self.rollPolicy.everyDay() || self.rollPolicy.everyHour() || self.rollPolicy.everyMinute() || self.rollPolicy.atHour() >= 0 || self.rollPolicy.atMinute() >= 0 {
//                            tags.append(.date)
//                        }
//                        self.rollFile(tags: tags)
//                        self.suspendedMonitoring = false
//                    }
//                }
//            }
//        }
//    }
//    
//    private func generateArchiveFilename(tags:[FileRollTag]) -> String {
//        var majorPartOfFilename = self._filename.substring(from: 0, to: self._filename.count-4)
//        
//        if tags.contains(.date) {
//            let prevTimeTag = self.lastTimeTag
//            
//            // generate next time tag
//            let now = Date()
//            var requireHour = 0
//            var requireMinute = 0
//            if self.rollPolicy.everyDay() { // 20231114.0000
//                requireHour = 0
//                requireMinute = 0
//            }
//            if self.rollPolicy.everyMinute() || self.rollPolicy.atMinute() >= 0 { // 20231114.0022
//                requireMinute = Calendar.current.component(.minute, from: now)
//            }
//            if self.rollPolicy.everyHour() || self.rollPolicy.atHour() >= 0 { // 20231114.1100 or 20231114.1122
//                requireHour = Calendar.current.component(.hour, from: now)
//            }
//            
//            let date = Calendar.current.date(bySettingHour: requireHour, minute: requireMinute, second: 0, of: Date())!
//            
//            let nextTimeTag = date.string(format: self.timeTagFormat)
//            majorPartOfFilename = "\(majorPartOfFilename).from_\(prevTimeTag)_to_\(nextTimeTag)"
//            self.lastTimeTag = nextTimeTag
//        }
//        
//        if tags.contains(.sequence) {
//            var existArchives = -1
//            do {
//                let items = try FileManager.default.contentsOfDirectory(atPath: self._folder)
//                for item in items {
//                    if item.contains(majorPartOfFilename) && item.hasSuffix(".log") {
//                        existArchives += 1
//                    }
//                }
//            }catch{
//                let msg = "\(LogType.iconOfType(LogType.error)) \(ISO8601DateFormatter().string(from: Date())) [FileLogger][\(self._id)][roll] Unable to list log files in \(self._folder) - \(error)"
//                self.write(message: msg)
//                print(msg)
//                return ""
//            }
//            return "\(majorPartOfFilename).\(existArchives+1).log"
//        }
//        
//        if tags.contains(.date) {
//            return "\(majorPartOfFilename).log"
//        }else{
//            return "\(majorPartOfFilename).rolled.log"
//        }
//    }
//    
//    private func rollFile(tags:[FileRollTag]) {
//        let archiveFilename = self.generateArchiveFilename(tags: tags)
//        guard archiveFilename != "" else {return}
//        
//        var fromPath = ""
//        var toPath = ""
//        do {
//            
//            if #available(macOS 13.0, *) {
//                fromPath = self._folder
//                toPath = URL(fileURLWithPath: _folder).appending(path: archiveFilename).path()
//            }else{
//                fromPath = self._folder
//                toPath = URL(fileURLWithPath: _folder).appendingPathComponent(archiveFilename).path
//            }
//            
//            try FileManager.default.moveItem(atPath: fromPath, toPath: toPath)
//            try "\(ISO8601DateFormatter().string(from: Date())) [FileLogger][\(self._id)][roll] continue from previous file \(archiveFilename).\n".write(to: self.logFileUrl, atomically: false, encoding: .utf8)
//        }catch{
//            
//            let msg = "\(LogType.iconOfType(LogType.error)) \(ISO8601DateFormatter().string(from: Date())) [FileLogger][\(self._id)][roll] Unable to archive log file \(fromPath) - \(error)"
//            self.write(message: msg)
//            print(msg)
//            return
//        }
//    }
}
