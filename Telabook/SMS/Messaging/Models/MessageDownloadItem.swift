//
//  MessageDownloadItem.swift
//  Telabook
//
//  Created by Anmol Rajpal on 25/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

class Download {
    //
    // MARK: - Variables And Properties
    //
    var isDownloading = false
    var resumeData:Data?
    var progress: Float = 0
    var task: URLSessionDownloadTask?
    var completionHandler:(() -> Void)?
    var message: UserMessage
    
    //
    // MARK: - Initialization
    //
    init(message: UserMessage) {
      self.message = message
    }
}
