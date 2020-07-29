//
//  UserMessage+MediaHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import MessageKit

extension UserMessage {
    
    enum MediaDownloadState:Int {
        case new = 0, downloaded, failed
        
        init(_ rawValue:Int) {
            switch rawValue {
                case 0: self = .new
                case 1: self = .downloaded
                case 2: self = .failed
                default: fatalError("Invalid case")
            }
        }
    }
    var downloadState:MediaDownloadState {
        get {
            MediaDownloadState(Int(mediaDownloadState))
        }
        set {
            mediaDownloadState = Int64(newValue.rawValue)
        }
    }
    
    
    enum MediaUploadState:Int {
        case none = 0, pending, uploaded, failed
        
        init(_ rawValue:Int) {
            switch rawValue {
                case 0: self = .none
                case 1: self = .pending
                case 2: self = .uploaded
                case 3: self = .failed
                default: fatalError("Invalid case")
            }
        }
    }
    var uploadState:MediaUploadState {
        get {
            MediaUploadState(Int(mediaUploadState))
        }
        set {
            mediaUploadState = Int64(newValue.rawValue)
        }
    }
    
    func imageLocalURL() -> URL? {
        guard let uuid = imageUUID else { return nil }
        let fileName = uuid.uuidString + ".jpeg"
        guard let con = conversation else {
            print("Failed to unwrap conversation")
            return nil
        }
        let mediaFolder = con.mediaFolder()
        //        print("Media folder url: \(mediaFolder)")
        let url = mediaFolder.appendingPathComponent(fileName)
        return url
    }
    
    
    
    
    var uploadRequest: URLRequest? {
        guard let url = imageURL else { return nil }
        var request = URLRequest(url: url)
        request.setValue(Header.contentType.image·jpeg.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        request.httpMethod = HTTPMethod.POST.rawValue
        return request
    }
    
    
    /**
     Load the image from the cached file if it exists, otherwise from the attachment’s imageData.
     
     Attachments created by Core Data with CloudKit don’t have cached files.
     Provide a new task context to load the image data, and release it after the image finishes loading.
     */
    func getImage() -> UIImage? {
        guard let data = getImageData() else { return nil }
        return UIImage(data: data)
    }
    
    func getDownsampledImage() -> UIImage? {
        guard let imageData = getImageData() else { return nil }
        
        let maxDimensionInPixels = max(270, 270) * 1
        let options = [kCGImageSourceCreateThumbnailWithTransform: true,
                       kCGImageSourceCreateThumbnailFromImageAlways: true,
                       kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil)!
        let imageReference = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options)!
        return UIImage(cgImage: imageReference)
    }
    
    func getImageData() -> Data? {
        guard let url = imageLocalURL() else { return nil }
        var imageData:Data?
        var nsError: NSError?
        NSFileCoordinator().coordinate(
            readingItemAt: url, options: .withoutChanges, error: &nsError,
            byAccessor: { (newURL: URL) -> Void in
                if let data = try? Data(contentsOf: newURL) {
                    imageData = data
                }
        })
        if let nsError = nsError {
            print("###\(#function): \(nsError.localizedDescription)")
        }
        return imageData
    }
}
