//
//  MessageUploadItem.swift
//  Telabook
//
//  Created by Anmol Rajpal on 25/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

class Upload {
    //
    // MARK: - Variables And Properties
    //
    var isUploading = false
    var progress: Float = 0
    var task: URLSessionUploadTask?
    var completionHandler:(() -> Void)?
    var message: UserMessage
    
    //
    // MARK: - Initialization
    //
    init(message: UserMessage) {
      self.message = message
    }
}
