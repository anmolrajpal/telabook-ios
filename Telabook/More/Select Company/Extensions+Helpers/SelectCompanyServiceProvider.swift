//
//  SelectCompanyServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/04/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

extension SelectCompanyViewController {
    
    
    internal func fetchUserCompanies() {
        DispatchQueue.main.async {
            self.subview.spinner.startAnimating()
        }
        APIService.shared.GET(endpoint: .FetchUserCompanies, guardResponse: .OK) { (result: Result<[UserCompaniesCodable]?, APIService.APIError>) in
            switch result {
                case let .success(data): self.handleFetchUserCompaniesWithSuccess(userCompanies: data)
                case let .failure(error): self.handleFetchUserCompaniesFaliure(error: error)
            }
        }
    }
    
    
    
    internal func handleFetchUserCompaniesWithSuccess(userCompanies: [UserCompaniesCodable]?) {
        guard let companies = userCompanies, !companies.isEmpty else {
            DispatchQueue.main.async {
                self.subview.spinner.stopAnimating()
                UIAlertController.showTelaAlert(title: "Error", message: "User Companies Not Found. Please contact support.", action: UIAlertAction(title: "Retry", style: .cancel, handler: { action in
                    self.fetchUserCompanies()
                }), controller: self)
            }
            return
        }
        self.userCompanies = companies
    }
    internal func handleFetchUserCompaniesFaliure(error: APIService.APIError) {
        DispatchQueue.main.async {
            self.subview.spinner.stopAnimating()
            UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription, action: UIAlertAction(title: "Retry", style: .cancel, handler: { action in
                self.fetchUserCompanies()
            }), controller: self)
        }
    }
}
