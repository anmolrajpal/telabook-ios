//
//  AgentGalleryItem.swift
//  Telabook
//
//  Created by Anmol Rajpal on 21/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

extension AgentGalleryItem {
    convenience init(context: NSManagedObjectContext, agentGalleryItemEntryFromFirebase entry: FirebaseAgentGalleryItem, agent:Agent, uuid:UUID?, state:MediaState) {
        self.init(context: context)
        self.firebaseKey = entry.key
        self.date = entry.date
        let urlString = entry.url
        self.mediaItemUrlString = urlString
        if let urlString = urlString,
            let url = URL(string: urlString) {
            self.mediaItemURL = url
        }
        self.agent = agent
        self.uuid = uuid
        self.state = state
    }
}


extension AgentGalleryItem {
    enum MediaState:Int {
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
    var state:MediaState {
        get {
            MediaState(Int(mediaState))
        }
        set {
            mediaState = Int64(newValue.rawValue)
        }
    }
    
    func imageLocalURL() -> URL? {
        guard let uuid = uuid else { return nil }
        let fileName = uuid.uuidString + ".jpeg"
        let url = agent!.mediaFolder().appendingPathComponent(fileName)
        return url
    }
    
    
    
    
    var uploadRequest: URLRequest? {
        guard let url = mediaItemURL else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        return request
    }
    
    
    
    func getImage() -> UIImage? {
        // Load the image from the cached file if the file exists.
        guard let url = imageLocalURL() else { return nil }
        var image: UIImage?
        
        var nsError: NSError?
        NSFileCoordinator().coordinate(
            readingItemAt: url, options: .withoutChanges, error: &nsError,
            byAccessor: { (newURL: URL) -> Void in
                if let data = try? Data(contentsOf: newURL) {
                    image = UIImage(data: data, scale: UIScreen.main.scale)
                }
        })
        if let nsError = nsError {
            print("###\(#function): \(nsError.localizedDescription)")
        }
        return image
    }
}




extension AgentGalleryItem {

}
