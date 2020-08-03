//
//  Enums.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit


public enum MediaAutoDownloadState:CaseIterable, RawRepresentable {
    case never, wifi, wifiPlusCellular
    
    public init(rawValue: Int) {
        switch rawValue {
            case 0: self = .never
            case 1: self = .wifi
            case 2: self = .wifiPlusCellular
            default: fatalError("Invalid Case for Media Auto Download State Init")
        }
    }
    public var rawValue:Int {
        switch self {
            case .never: return 0
            case .wifi: return 1
            case .wifiPlusCellular: return 2
        }
    }
    var stringValue: String {
        switch self {
            case .never: return "Never"
            case .wifi: return "Wi-Fi Only"
            case .wifiPlusCellular: return "Wi-Fi and Cellular"
        }
    }
}

public enum AppUserRole {
    case Developer, Owner, Operator, Agent
    
    static func getUserRole(byRoleCode code: Int) -> AppUserRole {
        switch code {
            case 1: return .Developer
            case 2: return .Owner
            case 3: return .Operator
            case 4: return .Agent
            default: fatalError("Invalid or Unhandled Role")
        }
    }
    static func getUserRoleCode(byUserRole role: AppUserRole) -> Int {
        switch role {
            case .Developer: return 1
            case .Owner: return 2
            case .Operator: return 3
            case .Agent: return 4
        }
    }
    
    var stringValue:String {
        String(describing: self)
    }
}

public enum UserRole {
    case SuperUser
    case Admin
    case Receptionist
    case Agent
    
    static func getRole(by code: Int) -> UserRole {
        switch code {
        case 1: return .SuperUser
        case 2: return .Admin
        case 3: return .Receptionist
        case 4: return .Agent
        default: fatalError("Invalid Role")
        }
    }
    static func getCode(by role: UserRole) -> Int {
        switch role {
        case .SuperUser: return 1
        case .Admin: return 2
        case .Receptionist: return 3
        case .Agent: return 4
        }
    }
    
}

public enum URLScheme:String {
    case http, https
}
public enum APIServiceError:Error {
    case apiError, InvalidEndpoint, InvalidResponse, FailedRequest, NoData, Internal, DecodeError, Unknown
}
public enum HTTPMethod:String {
    case GET, POST, PUT, DELETE
}
public enum ApplicationError:Error {
    case Internal(status:Int, message:String)
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
    case dateTimeType2 = "MMMM d, h:mm a"
    case ddMMyyyy·hmma = "dd/MM/yyyy, h:mm a"
//    case telaDateTim = CustomDateFormat.telaDateTime()
    /// Date
    case chatHeaderDate = "EEEE, MMM d, yyyy"
    case date = "dd/MM/yyyy"
    case dateType1 = "dd MMM, yyyy"
    case dateType2 = "MMM d"
    case MMMMdEEEE = "MMMM d EEEE"
    case ddMMMyyyy = "dd MMM yyyy"
    
    static func telaDateTime() -> String {
        return "\(self.ddMMMyyyy.rawValue) | \(self.hmma.rawValue)"
        
    }
}
public enum TextFieldItemPosition {
    case Left
    case Right
}
enum ServerResult {
    case success, failure
}
extension ServerResult: RawRepresentable {
    typealias ServerResultValue = String
    
    init(rawValue: ServerResultValue) {
        switch rawValue {
            case "success": self = .success
            case "failure": self = .failure
            default: fatalError("Unhandled case for Server Result Type")
        }
    }
    var rawValue: ServerResultValue {
        String(describing: self)
    }
}

public enum httpMethod:String {
    case GET
    case POST
    case PUT
    case DELETE
}
public enum UrlScheme:String {
    case http, https
}
public enum ServiceError:Error {
    case Unknown
    case FailedRequest
    case InvalidResponse
    case Internal
    
}
public enum ChatMessageType {
    case SMS
    case MMS
    static func getMessageType(by typeCode:String) -> ChatMessageType {
        switch typeCode {
        case "sms": return .SMS
        case "mms": return .MMS
        default: return .SMS
        }
    }
    static func getMessageTypeCode(by type:ChatMessageType) -> String {
        switch type {
        case .SMS: return "sms"
        case .MMS: return "mms"
        }
    }
}
public enum CustomerPriority {
    case None, Low, Medium, High
    
    static func priority(from code:Int) -> Self {
        switch code {
            case 0: return .None
            case 1: return .Low
            case 2: return .Medium
            case 3: return .High
            default: fatalError("Unhandled Case for Customer Priority")
        }
    }
   
    var code:Int {
        switch self {
            case .None: return 0
            case .Low: return 1
            case .Medium: return 2
            case .High: return 3
        }
    }
    var color:UIColor {
        switch self {
            case .None: return .telaGray5
            case .Low: return .telaGreen
            case .Medium: return .telaYellow
            case .High: return .telaRed
        }
    }
    var image:UIImage {
        switch self {
            case .None: return #imageLiteral(resourceName: "followup_low")
            case .Low: return #imageLiteral(resourceName: "followup_low").withTintColor(.telaGreen)
            case .Medium: return #imageLiteral(resourceName: "followup_medium")
            case .High: return #imageLiteral(resourceName: "followup_high")
        }
    }
}
public enum CustomerConversationColor {
    case White, Yellow, Blue, Green
    
    static func colorCase(from colorCode:Int) -> CustomerConversationColor {
        switch colorCode {
            case 1: return .Yellow
            case 2: return .Blue
            case 3: return .Green
            default: return .White
        }
    }
    var code:Int {
        switch self {
            case .Yellow: return 1
            case .Blue: return 2
            case .Green: return 3
            case .White: return 99
        }
    }
    var color:UIColor {
        switch self {
            case .Yellow: return .telaYellow
            case .Blue: return .telaBlue
            case .Green: return .telaGreen
            case .White: return .telaWhite
        }
    }
    var colorName:String {
        String(describing: self)
    }
}
public enum MessageCategory {
    case text, multimedia, scheduled, system
    
    init(stringValue type:String) {
        switch type {
            case "TEXT_ONLY", "TEXT", "sms", "SMS", "text", "Text": self = .text
            case "MULTIMEDIA", "mms", "MMS", "Multimedia", "multimedia": self = .multimedia
            case "SCHEDULED_MESSAGE", "scheduled": self = .scheduled
            case "NOTE", "note", "SYSTEM_MESSAGE", "system": self = .system
            default: fatalError("Unhandled case for Message Type value: <\(type)>")
        }
    }
    
    static func messageType(from string:String) -> Self {
        switch string {
            case "TEXT_ONLY", "TEXT", "sms", "SMS", "text", "Text": return .text
            case "MULTIMEDIA", "mms", "MMS", "Multimedia": return .multimedia
            case "SCHEDULED_MESSAGE": return .scheduled
            case "NOTE", "SYSTEM_MESSAGE": return .system
            default: fatalError("Unhandled case for Message Type value: \(string)")
        }
    }
    var rawValue:String { String(describing: self) }
    var serverValue:String {
        switch self {
            case .text: return "TEXT"
            case .multimedia: return "MULTIMEDIA"
            case .scheduled: return "SCHEDULED_MESSAGE"
            case .system: return "SYSTEM_MESSAGE"
        }
    }
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
    case Gone
    case PreconditionFailed
    case PayloadTooLarge
    case uriTooLong
    case UnsupportedMediaType
    case ExpectationFailed
    case MisdirectedRequest
    case UnprocessableEntity
    case Locked
    case FailedDependency
    case TooManyRequests
    //5xx
    case InternalServerError
    case NotImplemented
    case BadGateway
    case ServiceUnavailable
    //Custom
    case UnknownResponse
    
    var rawValue:String {
        String(describing: self)
    }
    
    static func getStatusCode(by status:ResponseStatus) -> Int {
        switch status {
        //2xx
        case .OK: return 200
        case .Created: return 201
        case .Accepted: return 202
        case .NoContent: return 204
        //4xx
        case .BadRequest: return 400
        case .Unauthorized: return 401
        case .Forbidden: return 403
        case .NotFound: return 404
        case .MethodNotAllowed: return 405
        case .RequestTimeout: return 408
        case .Conflict: return 409
        case .Gone: return 410
        case .PreconditionFailed: return 412
        case .PayloadTooLarge: return 413
        case .uriTooLong: return 414
        case .UnsupportedMediaType: return 415
        case .ExpectationFailed: return 417
        case .MisdirectedRequest: return 421
        case .UnprocessableEntity: return 422
        case .Locked: return 423
        case .FailedDependency: return 424
        case .TooManyRequests: return 429
        //5xx
        case .InternalServerError: return 500
        case .NotImplemented: return 501
        case .BadGateway: return 502
        case .ServiceUnavailable: return 503
        //Unknown
        case .UnknownResponse: return 0
        }
    }
    
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
        case 410: return .Gone
        case 412: return .PreconditionFailed
        case 413: return .PayloadTooLarge
        case 414: return .uriTooLong
        case 415: return .UnsupportedMediaType
        case 417: return .ExpectationFailed
        case 421: return .MisdirectedRequest
        case 422: return .UnprocessableEntity
        case 423: return .Locked
        case 424: return .FailedDependency
        case 429: return .TooManyRequests
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
        case xRequestedWith = "X-Requested-With"
        case Authorization
    }
    enum HeaderValue:String {
        case XMLHttpRequest = "XMLHttpRequest"
    }
    enum contentType:String {
        case json = "application/json"
        case xml = "application/xml"
        case urlEncoded = "application/x-www-form-urlencoded"
        case image·jpeg = "image/jpeg"
    }
    enum accept:String {
        case json = "application/json"
        case jsonFormatted = "application/json;indent=2"
        case xml = "application/xml"
    }
}


struct HTTPHeader {
    let key:HeaderKey
    let value:String
    
    enum HeaderKey:String {
        case Authorization
        case cacheControl = "Cache-Control"
        case postmanToken = "Postman-Token"
        case xRequestedWith = "X-Requested-With"
        case contentType = "Content-Type"
        case contentLength = "Content-Length"
        case Host
        case userAgent = "User-Agent"
        case Accept
        case acceptEncoding = "Accept-Encoding"
        case Connection
    }
}




public enum MessageKitError {
    internal static let avatarPositionUnresolved = "AvatarPosition Horizontal.natural needs to be resolved."
    internal static let nilMessagesDataSource = "MessagesDataSource has not been set."
    internal static let nilMessagesDisplayDelegate = "MessagesDisplayDelegate has not been set."
    internal static let nilMessagesLayoutDelegate = "MessagesLayoutDelegate has not been set."
    internal static let notMessagesCollectionView = "The collectionView is not a MessagesCollectionView."
    internal static let layoutUsedOnForeignType = "MessagesCollectionViewFlowLayout is being used on a foreign type."
    internal static let unrecognizedSectionKind = "Received unrecognized element kind:"
    internal static let unrecognizedCheckingResult = "Received an unrecognized NSTextCheckingResult.CheckingType"
    internal static let couldNotLoadAssetsBundle = "MessageKit: Could not load the assets bundle"
    internal static let couldNotCreateAssetsPath = "MessageKit: Could not create path to the assets bundle."
    internal static let customDataUnresolvedCell = "Did not return a cell for MessageKind.custom(Any)."
    internal static let customDataUnresolvedSize = "Did not return a size for MessageKind.custom(Any)."
}
