//
//  AppManager.swift
//  Telabook
//
//  Created by Anmol Rajpal on 23/10/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreTelephony

enum NetworkType: Int {
    case network_none = 0
    case network_2g = 1
    case network_3g = 2
    case network_lte = 3
    case network_5g = 4
    case network_wifi = 5
}

/*
* AppManager is a class that includes some useful functions.
*/
@objc class AppManager: NSObject {
    /*
    @available(iOS, deprecated: 12.0)
    static func network() -> NetworkType {
        let info = CTTelephonyNetworkInfo()
        let currentRadio = info.currentRadioAccessTechnology
        if (currentRadio == CTRadioAccessTechnologyEdge) {
            return NetworkType.network_2g
        } else if (currentRadio == CTRadioAccessTechnologyLTE) {
            return NetworkType.network_lte
        }
        return NetworkType.network_3g
    }
    */
    func network() -> NetworkType {
        let info = CTTelephonyNetworkInfo()
        if let radioServices = info.serviceCurrentRadioAccessTechnology, !radioServices.isEmpty {
            let currentRadio = radioServices.values.first!
            if #available(iOS 14.1, *) {
                if currentRadio == CTRadioAccessTechnologyNRNSA || currentRadio == CTRadioAccessTechnologyNR {
                    // TODO: Handle 5G
                    return .network_5g
                }
            }
            switch currentRadio {
            case CTRadioAccessTechnologyGPRS,
                 CTRadioAccessTechnologyEdge,
                 CTRadioAccessTechnologyCDMA1x:
                return .network_2g
            case CTRadioAccessTechnologyWCDMA,
                 CTRadioAccessTechnologyHSDPA,
                 CTRadioAccessTechnologyHSUPA,
                 CTRadioAccessTechnologyCDMAEVDORev0,
                 CTRadioAccessTechnologyCDMAEVDORevA,
                 CTRadioAccessTechnologyCDMAEVDORevB,
                 CTRadioAccessTechnologyeHRPD:
                return .network_3g
            case CTRadioAccessTechnologyLTE:
                return .network_lte
            default: fatalError()
            }
        } else {
            return .network_none
        }
    }

    @objc static func recordingFilePathFromCall(address: String) -> String {
        var filePath = "recording_"
        filePath = filePath.appending(address.isEmpty ? "unknow" : address)
        let now = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "E-d-MMM-yyyy-HH-mm-ss"
        let date = dateFormat.string(from: now)
        
        filePath = filePath.appending("_\(date).mkv")
        
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        var writablePath = paths[0]
        writablePath = writablePath.appending("/\(filePath)")
        print("file path is \(writablePath)")
        return writablePath
        //file name is recording_contact-name_dayName-day-monthName-year-hour-minutes-seconds
        //The recording prefix is used to identify recordings in the cache directory.
        //We will use name_dayName-day-monthName-year to separate recordings by days, then hour-minutes-seconds to order them in each day.
    }
}
