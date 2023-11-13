//
//  Defaults.swift
//
//
//  Created by Kelvin Wong on 2023/11/14.
//

import Foundation

public struct Defaults {
    
    
    public static func defaultLoggingFilename() -> String {
        return FilenameGenerator.default.new().date(format: "yyyy-MM-dd_HHmm").append(text: ".log").get()
    }
    
    public static func defaultLoggingDirectory() -> String {
        return DirectoryGenerator.default.new().userDocuments().subfolder("log").get()
    }
}
