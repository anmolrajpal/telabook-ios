//
//  CustomerDetails+ServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension CustomerDetailsController {
    
    
    func fetchInitialConversationsHistory() {
        guard let phoneNumber = conversation.phoneNumber, !phoneNumber.isBlank else {
            showAlert(withErrorMessage: "Error: Customer phone number is missing.")
            return
        }
        fetchConversationsHistory(forCustomerPhoneNumber: phoneNumber, page: currentPageIndex + 1)
    }
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func fetchConversationsHistory(forCustomerPhoneNumber phoneNumber: String, page: Int) {
        isFetching = true
        if lookupConversations.isEmpty {
            self.startHistorySpinner()
            self.historyPlaceholderLabel.text = "Loading..."
            self.historyPlaceholderLabel.isHidden = false
        }
        
        let params: [String: String] = [
            "company_id": String(AppData.companyId),
            "search": phoneNumber,
            "limit": String(limit),
            "page": String(page)
        ]
        
        APIServer<LookupConversationJSON>(apiVersion: .v2).hitEndpoint(endpoint: .SearchConversations, httpMethod: .POST, params: params, decoder: JSONDecoder.apiServiceDecoder, completion: historyFetchCompletion)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    private func historyFetchCompletion(result: Result<LookupConversationJSON, APIService.APIError>) {
        switch result {
            case .failure(let error):
                self.isFetching = false
                self.showAlert(withErrorMessage: error.publicDescription)
            case .success(let resultData):
                let serverResult = resultData.result
                switch serverResult {
                    case .failure:
                        self.isFetching = false
                        let errorMessage = "Error: No results from server"
                        self.showAlert(withErrorMessage: resultData.message ?? errorMessage)
                    case .success:
                        self.lookupConversations.append(contentsOf: resultData.conversations)
                        self.currentPageIndex = resultData.page
                        self.isFetching = false
                        DispatchQueue.main.async {
                            self.updateUI()
                    }
            }
        }
    }
    
    
    
    
    
    func fetchCustomerDetails() {
        let customerID = Int(conversation.customerID)
        let conversationID = String(conversation.externalConversationID)
        guard let worker = conversation.agent else {
            fatalError("### \(#function) - Failed to retrieve agent from conversation: \(conversation)")
        }
        let workerID = String(worker.workerID)
        
        fetchCustomerDetails(customerId: customerID, conversationId: conversationID, workerId: workerID)
    }
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func fetchCustomerDetails(customerId: Int, conversationId: String, workerId: String) {
        
        
        self.startDetailsSpinner()
        self.updateButton.isHidden = true
        
        
        let params: [String: String] = [
            "company_id": String(AppData.companyId),
            "worker_id": workerId,
            "conversation_id": conversationId
        ]
        
        APIServer<CustomerDetailsJSON>(apiVersion: .v2).hitEndpoint(endpoint: .FetchCustomerDetails(customerID: customerId), httpMethod: .GET, params: params, decoder: JSONDecoder.apiServiceDecoder, completion: customerDetailsFetchCompletion)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    private func customerDetailsFetchCompletion(result: Result<CustomerDetailsJSON, APIService.APIError>) {
        switch result {
            case .failure(let error):
                self.showAlert(withErrorMessage: error.publicDescription) {
                    self.stopDetailsSpinner()
                    self.updateButton.isHidden = false
            }
            case .success(let resultData):
                let serverResult = resultData.result
                switch serverResult {
                    case .failure:
                        let errorMessage = "Error: Failed to fetch customer details from server"
                        self.showAlert(withErrorMessage: resultData.message ?? errorMessage) {
                            self.stopDetailsSpinner()
                            self.updateButton.isHidden = false
                    }
                    case .success:
                        guard let customerDetails = resultData.customerDetails else {
                            let errorMessage = "Error: Customer details unavailable"
                            self.showAlert(withErrorMessage: errorMessage) {
                                self.stopDetailsSpinner()
                                self.updateButton.isHidden = false
                            }
                            return
                        }
                        guard let context = conversation.managedObjectContext else {
                            fatalError("### \(#function) - Failed to retrieve managed object context of conversation: \(conversation)")
                        }
                        //                    let context = PersistentContainer.shared.viewContext
                        context.performAndWait {
                            if conversation.customerDetails == nil {
                                _ = CustomerDetails(context: context, customerDetailsEntryFromServer: customerDetails, conversationWithCustomer: conversation)
                            } else {
                                conversation.customerDetails?.updateData(fromCustomerDetailsEntryFromServer: customerDetails)
                            }
                            do {
                                if context.hasChanges { try context.save() }
                            } catch {
                                printAndLog(message: "### \(#function) \(error.localizedDescription)", log: .coredata, logType: .error)
                                fatalError(error.localizedDescription)
                            }
                        }
                        DispatchQueue.main.async {
                            self.stopDetailsSpinner()
                            self.updateButton.isHidden = false
                            self.setupCustomerDetails()
                    }
            }
        }
    }
    
    
    
    
    
    
    func updateCustomerDetails() {
        guard let worker = conversation.agent else {
            fatalError("### \(#function) - Failed to retrieve agent from conversation: \(conversation)")
        }
        let customerID = Int(conversation.customerID)
        let workerID = String(worker.workerID)
        let agentOnlyName = agentOnlyNameTextField.text ?? ""
        let globalName = globalNameTextField.text ?? ""
        updateCustomerDetails(customerId: customerID, conversationId: conversationID, workerId: workerID, agentOnlyName: agentOnlyName, globalName: globalName)
    }
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    private func updateCustomerDetails(customerId: Int, conversationId: Int, workerId: String, agentOnlyName: String, globalName: String) {
        TapticEngine.generateFeedback(ofType: .Medium)
        
        self.startDetailsSpinner()
        self.updateButton.isHidden = true
        
        let headers:[HTTPHeader] = [
            HTTPHeader(key: .contentType, value: Header.contentType.json.rawValue)
        ]
        let params: [String: String] = [
            "company_id": String(AppData.companyId),
            "worker_id": workerId
        ]
        struct Body: Encodable {
            let agent_only_name: String
            let names: String
            let conversation_id: Int
        }
        let body = Body(agent_only_name: agentOnlyName, names: globalName, conversation_id: conversationId)
        let httpBody = try! JSONEncoder().encode(body)
        
        APIServer<APIService.RecurrentResult>(apiVersion: .v2).hitEndpoint(endpoint: .UpdateCustomerDetails(customerID: customerId), httpMethod: .PUT, params: params, httpBody: httpBody, headers: headers, completion: customerDetailsUpdateCompletion)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    private func customerDetailsUpdateCompletion(result: Result<APIService.RecurrentResult, APIService.APIError>) {
        switch result {
            case .failure(let error):
                self.showAlert(withErrorMessage: error.publicDescription) {
                    TapticEngine.generateFeedback(ofType: .Error)
                    self.stopDetailsSpinner()
                    self.updateButton.isHidden = false
            }
            case .success(let resultData):
                let serverResult = ServerResult(rawValue: resultData.result!)
                
                switch serverResult {
                    case .failure:
                        let errorMessage = "Error: Failed to update customer details"
                        self.showAlert(withErrorMessage: resultData.message ?? errorMessage) {
                            TapticEngine.generateFeedback(ofType: .Error)
                            self.stopDetailsSpinner()
                            self.updateButton.isHidden = false
                    }
                    case .success:
                        DispatchQueue.main.async {
                            TapticEngine.generateFeedback(ofType: .Success)
                            AssertionModalController(title: "Updated").show()
                            self.stopDetailsSpinner()
                            self.updateButton.isHidden = false
                            self.fetchCustomerDetails()
                    }
            }
        }
    }
    
    
    
    
    private func showAlert(withErrorMessage message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIAlertController.showTelaAlert(title: "Error", message: message, action: UIAlertAction(title: "OK", style: .cancel, handler: { action in
                completion?()
            }), controller: self, completion: {
                self.updateUI()
            })
        }
    }
}
