//
//  AppLogger.swift
//  Snabum
//
//  Created by mac on 30/07/2025.
//

import os
import Foundation

final class AppLogger {
    
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.et.snapbum"

    static let general = Logger(subsystem: subsystem, category: "general")
    static let network = Logger(subsystem: subsystem, category: "network")
    static let auth = Logger(subsystem: subsystem, category: "auth")
    static let error = Logger(subsystem: subsystem, category: "error")
    static let debug = Logger(subsystem: subsystem, category: "debug")
    
}
