//
//  LinphoneLoggingServiceManager.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/11/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//


import linphonesw
#if USE_CRASHLYTICS
import Firebase
#endif

enum LinphoneError: Error {
    case timeout
    case loggingServiceUninitialized
}


class LinphoneLoggingServiceManager: LoggingServiceDelegate {
    init(config: linphonesw.Config, log: LoggingService?, domain: String) throws {
        if let log = log {
            super.init()
            let debugLevel = config.getInt(section: "app", key: "debugenable_preference", defaultValue: LogLevel.Debug.rawValue)
            let debugEnabled = (debugLevel >= LogLevel.Debug.rawValue && debugLevel < LogLevel.Error.rawValue)

            if (debugEnabled) {
                Factory.Instance.logCollectionPath = Factory.Instance.getDownloadDir(context: UnsafeMutablePointer<Int8>(mutating: ("" as NSString).utf8String)) // GroupAppID to enter in context
                Factory.Instance.enableLogCollection(state: LogCollectionState.Enabled)
                log.domain = domain
                log.logLevel = LogLevel(rawValue: debugLevel)
                log.addDelegate(delegate: self)
            }
        } else {
            throw LinphoneError.loggingServiceUninitialized
        }
    }

    override func onLogMessageWritten(logService: LoggingService, domain: String, lev: LogLevel, message: String) {
        let level: String

        switch lev {
        case .Debug:
            level = "Debug"
        case .Trace:
            level = "Trace"
        case .Message:
            level = "Message"
        case .Warning:
            level = "Warning"
        case .Error:
            level = "Error"
        case .Fatal:
            level = "Fatal"
        default:
            level = "unknown"
        }

#if USE_CRASHLYTICS
        Crashlytics.crashlytics().log("\(level) [\(domain)] \(message)\n")
#endif
        NSLog("[\(level)] [\(domain)] \(message)\n")
    }
}
