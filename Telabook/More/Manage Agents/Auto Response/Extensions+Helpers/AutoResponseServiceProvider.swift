//
//  AutoResponseServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 06/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension AutoResponseViewController {
    internal func fetchAutoResponse() {
        /*
        startSpinner()
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = agent.objectID
        let agentRefrenceObject = context.object(with: objectID) as! Agent
        let operations = AutoResponseOperations.getOperationsToFetchAndSaveAutoResponse(using: context, userID: userID, forAgent: agentRefrenceObject)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue)
        
        queue.addOperations(operations, waitUntilFinished: false)
        */
        
        
        let userId = String(agent.userID)
        fetchAutoResponse(userId: userId)
    }
    
    
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    private func fetchAutoResponse(userId: String) {
        startSpinner()
        subview.saveButton.isHidden = true
        
        let params: [String: String] = [
            "company_id": String(AppData.companyId),
            "user_id": userId
        ]
        
        APIServer<AutoResponseJSON>(apiVersion: .v2).hitEndpoint(endpoint: .AutoResponse, httpMethod: .GET, params: params, decoder: JSONDecoder.apiServiceDecoder, completion: autoResponseFetchCompletion)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    private func autoResponseFetchCompletion(result: Result<AutoResponseJSON, APIService.APIError>) {
        switch result {
            case .failure(let error):
                self.showAlert(withErrorMessage: error.localizedDescription) {
                    self.stopSpinner()
                    self.subview.saveButton.isHidden = false
            }
            case .success(let resultData):
                let serverResult = resultData.result
                switch serverResult {
                    case .failure:
                        let errorMessage = "Error: Failed to fetch customer details from server"
                        self.showAlert(withErrorMessage: resultData.message ?? errorMessage) {
                            self.stopSpinner()
                            self.subview.saveButton.isHidden = false
                    }
                    case .success:
                        guard let autoResponse = resultData.autoResponse else {
                            let errorMessage = "Error: Auto Response unavailable"
                            self.showAlert(withErrorMessage: errorMessage) {
                                self.stopSpinner()
                                self.subview.saveButton.isHidden = false
                            }
                            return
                        }
                        guard let context = agent.managedObjectContext else {
                            fatalError("### \(#function) - Failed to retrieve managed object context of Agent object: \(agent)")
                        }
                        context.performAndWait {
                            if agent.autoResponse == nil {
                                _ = AutoResponse(context: context, autoResponseEntry: autoResponse, agent: agent, synced: true)
                            } else {
                                agent.autoResponse?.updateValues(autoResponseEntry: autoResponse)
                            }
                            do {
                                if context.hasChanges { try context.save() }
                            } catch {
                                printAndLog(message: "### \(#function) \(error.localizedDescription)", log: .coredata, logType: .error)
                                fatalError(error.localizedDescription)
                            }
                        }
                        DispatchQueue.main.async {
                            self.stopSpinner()
                            self.subview.saveButton.isHidden = false
                            self.setupData()
                    }
            }
        }
    }
    
    
    
    
    
    
    internal func updateAutoResponse() {
        /*
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = agent.objectID
        let agentRefrenceObject = context.object(with: objectID) as! Agent
        let operations = AutoResponseOperations.getOperationsToUpdateAutoResponseToServer(using: context, userID: userID, autoResponseID: id, forAgent: agentRefrenceObject, smsReplyToUpdate: subview.autoReplyTextView.text ?? "")
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue)
        
        queue.addOperations(operations, waitUntilFinished: false)
        */
        
        guard let responseID = agent.autoResponse?.id,
            responseID != 0 else {
            showAlert(withErrorMessage: "Error: Auto response does not exists. Please refresh")
            return
        }
        let smsReply = subview.autoReplyTextView.text ?? ""
        let userID = Int(agent.userID)
        
        updateAutoResponse(responseID: Int(responseID), userID: userID, smsReply: smsReply)
    }
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    private func updateAutoResponse(responseID: Int, userID: Int, smsReply: String) {
        TapticEngine.generateFeedback(ofType: .Medium)
        
        startSpinner()
        subview.saveButton.isHidden = true
        
        struct Body:Codable {
            let id: Int
            let user_id: Int
            let company_id: String
            let sms_replay: String
        }
        
        let headers = [
            HTTPHeader(key: .contentType, value: "application/json"),
        ]
        let companyId = String(AppData.companyId)
        let params: [String: String] = [
            "company_id": companyId,
        ]
        let body = Body(id: responseID, user_id: userID, company_id: companyId, sms_replay: smsReply)
        let httpBody = try! JSONEncoder().encode(body)
        
        
        APIServer<APIService.RecurrentResult>(apiVersion: .v2).hitEndpoint(endpoint: .AutoResponse, httpMethod: .POST, params: params, httpBody: httpBody, headers: headers, completion: autoResponseUpdateCompletion)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    private func autoResponseUpdateCompletion(result: Result<APIService.RecurrentResult, APIService.APIError>) {
        switch result {
            case .failure(let error):
                self.showAlert(withErrorMessage: error.localizedDescription) {
                    TapticEngine.generateFeedback(ofType: .Error)
                    self.stopSpinner()
                    self.subview.saveButton.isHidden = false
            }
            case .success(let resultData):
                let serverResult = ServerResult(rawValue: resultData.result!)
                
                switch serverResult {
                    case .failure:
                        let errorMessage = "Error: Failed to update customer details"
                        self.showAlert(withErrorMessage: resultData.message ?? errorMessage) {
                            TapticEngine.generateFeedback(ofType: .Error)
                            self.stopSpinner()
                            self.subview.saveButton.isHidden = false
                    }
                    case .success:
                        DispatchQueue.main.async {
                            TapticEngine.generateFeedback(ofType: .Success)
                            AssertionModalController(title: "Updated").show()
                            self.stopSpinner()
                            self.subview.saveButton.isHidden = false
                            self.fetchAutoResponse()
                    }
            }
        }
    }
    
    
    
    
    
    
    /*
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue) {
        operations.forEach { operation in
            switch operation {
                //MARK: Fetch & Sync Auto Response Operations
                case let operation as FetchSavedAgentAutoResponseEntry_Operation:
                    operation.completionBlock = {
                        if case let .failure(error) = operation.result {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            DispatchQueue.main.async {
                                
                            }
                        }
                }
                case let operation as DownloadAgentAutoResponseEntryFromServer_Operation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else { return }
                        print(error.localizedDescription)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                }
                case let operation as AddAgentAutoResponseEntryToCoreDataStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            DispatchQueue.main.async {
                                self.stopRefreshers()
                                self.updateSnapshot()
                            }
                        }
                }
                
                
                
                //MARK: Update AutoResponse to Server and Sync to Core Data Operations
                case let operation as SaveUserUpdatedAutoResponseEntryToStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            print("Response Saved in Core Data. Dismissing, leaving pending operations in Queue (updating on Server + sync to store)")
                            Thread.sleep(forTimeInterval: 0.4)
                            DispatchQueue.main.async {
                                self.stopRefreshers()
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                }
                case let operation as UpdateAgentAutoResponseEntryOnServer_Operation:
                operation.completionBlock = {
                        guard case let .failure(error) = operation.result else { return }
                        print(error.localizedDescription)
//                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                }
                case let operation as SyncUserUpdatedAutoResponseEntryFromServerToStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
//                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            print("Updated AutoResponse synced to core data")
                        }
                }
                default: break
            }
            
            
            
            
            /*
            if let operation = operation as? FetchSavedAgentAutoResponseEntry_Operation {
                operation.completionBlock = {
                    if case let .failure(error) = operation.result {
                        print(error.localizedDescription)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                    } else {
                        DispatchQueue.main.async {
//                            self.updateSnapshot()
                        }
                    }
                }
            } else if let operation = operation as? DownloadAgentAutoResponseEntryFromServer_Operation {
                operation.completionBlock = {
                    guard case let .failure(error) = operation.result else { return }
                    print(error.localizedDescription)
                    self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                }
            } else if let operation = operation as? AddAgentAutoResponseEntryToCoreDataStore_Operation {
                operation.completionBlock = {
                    if let error = operation.error {
                        print(error.localizedDescription)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                    } else {
                        DispatchQueue.main.async {
                            self.stopRefreshers()
                            self.updateSnapshot()
                        }
                    }
                }
            }
            */
        }
    }
    */
    private func showAlert(withErrorMessage message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIAlertController.showTelaAlert(title: "Error", message: message, action: UIAlertAction(title: "OK", style: .cancel, handler: { action in
                completion?()
            }), controller: self, completion: {
                
            })
        }
    }
//    private func showAlert(withErrorMessage message:String, cancellingOperationQueue queue:OperationQueue) {
//        DispatchQueue.main.async {
//            UIAlertController.showTelaAlert(title: "Error", message: message, action: UIAlertAction(title: "OK", style: .cancel, handler: { action in
//
//            }), controller: self, completion: {
//                queue.cancelAllOperations()
//            })
//        }
//    }
}
