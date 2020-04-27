//
//  SelectCompanyHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/04/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

extension SelectCompanyViewController {
    internal func setupTargetActions() {
        subview.selectButton.addTarget(self, action: #selector(didTapSelectButton), for: .touchUpInside)
    }
    @objc fileprivate func didTapSelectButton(_ sender:UIButton) {
        #if DEBUG
        print("didTapSelectButton")
        #endif
        guard let selectedCompanyId = selectedCompany.id, selectedCompanyId != 0 else {
            DispatchQueue.main.async {
                UIAlertController.showTelaAlert(title: "Error", message: "Invalid Company ID. Please contact support.", action: UIAlertAction(title: "Retry", style: .cancel, handler: { action in
                    self.fetchUserCompanies()
                }), controller: self)
            }
            return
        }
        AppData.companyId = selectedCompanyId
        self.dismiss(animated: true) {
            self.delegate?.didSelectCompany()
        }
    }
}
