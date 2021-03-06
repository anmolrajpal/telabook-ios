//
//  FirebaseOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 02/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

struct FirebaseOperations {
    /// Returns an array of operations for fetching the Firebase Auth Token used in API Calls as Bearer Token..
    static func getOperationsToFetchFirebaseToken() -> [Operation] {
        let fetchTokenOperation = FetchTokenOperation()
        return [fetchTokenOperation]
    }
}



class FetchTokenOperation: Operation {
    var result: Result<String, FirebaseAuthService.FirebaseError>?
    
    private var fetching = false
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return fetching
    }
    
    override var isFinished: Bool {
        return result != nil
    }
    
    override func cancel() {
        super.cancel()
    }
    
    func finish(result: Result<String, FirebaseAuthService.FirebaseError>?) {
        guard fetching else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        fetching = false
        self.result = result

        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }

    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        fetching = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        FirebaseAuthService.shared.getCurrentToken(completion: finish)
    }
}
