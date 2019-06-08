//
//  Enums.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
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
public enum ConversationPriority {
    case Low
    case Medium
    case High
    static func getPriority(by priorityCode: Int) -> ConversationPriority {
        switch priorityCode {
            case 1: return .Low
            case 2: return .Medium
            case 3: return .High
            default: return .Low
        }
    }
    static func getPriorityCode(by priority: ConversationPriority) -> Int {
        switch priority {
        case .Low: return 1
        case .Medium: return 2
        case .High: return 3
        }
    }
    static func getImage(by priority: ConversationPriority) -> UIImage {
        switch priority {
        case .Low: return #imageLiteral(resourceName: "followup_low")
        case .Medium: return #imageLiteral(resourceName: "followup_medium")
        case .High: return #imageLiteral(resourceName: "followup_high")
        }
    }
}
public enum ConversationColor {
    case Default
    case Yellow
    case Green
    case Blue
    static func getColorBy(colorCode:Int) -> ConversationColor {
        switch colorCode {
        case 0: return .Default
        case 1: return .Yellow
        case 2: return .Green
        case 3: return .Blue
        default: return .Default
        }
    }
    static func getColorCodeBy(color conversationColor:ConversationColor) -> Int {
        switch conversationColor {
        case .Default: return 0
        case .Yellow: return 1
        case .Green: return 2
        case .Blue: return 3
        }
    }
}
public enum ResponseStatus {
    //2xx
    case OK
    case Created
    case NoContent
    case Accepted
    //4xx
    case BadRequest
    case Unauthorized
    case Forbidden
    case NotFound
    case MethodNotAllowed
    case RequestTimeout
    case Conflict
    //5xx
    case InternalServerError
    case NotImplemented
    case BadGateway
    case ServiceUnavailable
    //Custom
    case UnknownResponse
    
    static func getResponseStatusBy(statusCode:Int) -> ResponseStatus {
        switch statusCode {
        //2xx
        case 200: return .OK
        case 201: return .Created
        case 202: return .Accepted
        case 204: return .NoContent
        //4xx
        case 400: return .BadRequest
        case 401: return .Unauthorized
        case 403: return .Forbidden
        case 404: return .NotFound
        case 405: return .MethodNotAllowed
        case 408: return .RequestTimeout
        case 409: return .Conflict
        //5xx
        case 500: return .InternalServerError
        case 501: return .NotImplemented
        case 502: return .BadGateway
        case 503: return .ServiceUnavailable
        default: return .UnknownResponse
        }
    }
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
