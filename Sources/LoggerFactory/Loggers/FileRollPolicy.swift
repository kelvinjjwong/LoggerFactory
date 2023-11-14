//
//  FileRollPolicy.swift
//  
//
//  Created by kelvinwong on 2023/11/14.
//

import Foundation

public enum FileRollTag {
    case sequence
    case date
}

public class FileRollPolicy {
    
    private var null = true
    
    private var rollAtSize: Int = 0
    private var rollAtSizeUnit: ByteCountFormatter.Units = .useBytes
    private var rollAtHour: Int = 0
    private var rollAtMinute: Int = 0
    private var rollEveryDay: Bool = false
    private var rollEveryHour: Bool = false
    private var rollEveryMinute: Bool = false
    
    private init() {
        self.null = true
    }
    
    public static func empty() -> FileRollPolicy {
        return FileRollPolicy()
    }
    
    public init(atSize: Int = 0, unit: ByteCountFormatter.Units = .useBytes, atHour: Int = -1, atMinute:Int = -1, everyDay:Bool = false, everyHour:Bool = false, everyMinute:Bool = false) {
        self.null = false
        
        self.rollAtSize = atSize
        self.rollAtSizeUnit = unit
        
        self.rollEveryDay = everyDay
        if everyDay {
            self.rollAtHour = 0
            self.rollAtMinute = 0
        }
        self.rollEveryHour = everyHour
        if everyHour {
            self.rollAtMinute = 0
        }
        self.rollEveryMinute = everyMinute
        
        self.rollAtHour = atHour
        self.rollAtMinute = atMinute
    }
    
    public func isAvailable() -> Bool {
        guard !self.null else {return false}
        
        return self.rollAtSize > 0
        || (self.rollEveryDay || self.rollEveryHour || self.rollEveryMinute ||
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
    
    public func everyDay() -> Bool {
        return self.rollEveryDay
    }
    
    public func everyHour() -> Bool {
        return self.rollEveryHour
    }
    
    public func everyMinute() -> Bool {
        return self.rollEveryMinute
    }
    
    public func toString() -> String {
        return """
FileRollPolicy: {empty: \(null), atSize: \(atSize()), unit: \(sizeUnit()), everyDay:\(everyDay()), everyHour:\(everyHour()), everyMinute:\(everyMinute()), atHour:\(atHour()), atMinute:\(atMinute())}
"""
    }
}
