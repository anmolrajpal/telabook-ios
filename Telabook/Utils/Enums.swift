//
//  Enums.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
public enum UserRole {
    case SuperUser
    case Admin
    case Receptionist
    case Agent
}
public enum CustomFonts:String {
    case gothamMedium = "Gotham-Medium"
    case gothamBook = "Gotham-Book"
}
public enum CustomDateFormat: String {
    /// Time
    case time = "HH:mm:ss"
    case hmma = "h:mm a"
    
    /// Date with hours
    case dateWithTime = "yyyy-MM-dd HH:mm:ss"
    case dateWithTimeType1 = "dd/MM/yyyy hh:mm:ss"
//    case telaDateTim = CustomDateFormat.telaDateTime()
    /// Date
    case date = "dd/MM/yyyy"
    case dateType1 = "dd MMM, yyyy"
    case dateType2 = "MMM d"
    case MMMMdEEEE = "MMMM d EEEE"
    case ddMMMyyyy = "dd MMM yyyy"
    
    static func telaDateTime() -> String {
        return "\(self.ddMMMyyyy.rawValue) | \(self.hmma.rawValue)"
    }
}
public enum TextFieldIconPosition {
    case Left
    case Right
}
public enum ResultType:String {
    case Success
    case Failure
}
public enum httpMethod:String {
    case GET
    case POST
    case PUT
}
public enum ServiceError:Error {
    case Unknown
    case FailedRequest
    case InvalidResponse
    case Internal
    
}
public enum Header {
    enum headerName:String {
        case contentType = "Content-Type"
        case accept = "Accept"
    }
    enum contentType:String {
        case json = "application/json"
        case xml = "application/xml"
        case urlEncoded = "application/x-www-form-urlencoded"
    }
    enum accept:String {
        case json = "application/json"
        case jsonFormatted = "application/json;indent=2"
        case xml = "application/xml"
    }
}
