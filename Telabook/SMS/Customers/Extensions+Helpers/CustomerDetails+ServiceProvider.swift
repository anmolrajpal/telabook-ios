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
    func historyFetchCompletion(result: Result<LookupConversationJSON, APIService.APIError>) {
        
        switch result {
            case .failure(let error):
                self.isFetching = false
                self.showAlert(withErrorMessage: error.localizedDescription)
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
