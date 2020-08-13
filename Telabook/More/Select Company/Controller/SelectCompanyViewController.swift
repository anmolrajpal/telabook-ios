//
//  SelectCompanyViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/04/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

protocol SelectCompanyDelegate {
    func didSelectCompany()
}

class SelectCompanyViewController: UIViewController {
    lazy private(set) var subview: SelectCompanyView = {
      return SelectCompanyView(frame: UIScreen.main.bounds)
    }()
    var delegate:SelectCompanyDelegate?
    var selectedCompany:UserCompaniesCodable! {
        didSet {
            guard let company = selectedCompany else { print("No Selected Company"); return }
            #if !RELEASE
            print("Selected Company- \(company.name ?? "nil"), ID: \(company.id ?? 0)")
            #endif
        }
    }
    var userCompanies:[UserCompaniesCodable] = [] {
        didSet {
            guard !userCompanies.isEmpty else {
                #if !RELEASE
                print("No User Companies")
                #endif
                return
            }
            let savedCompanyId = AppData.companyId
            print("Saved Company ID= \(savedCompanyId)")
            if savedCompanyId != 0 {
                print("Saved Company ID not 0")
                self.selectedCompany = userCompanies.first(where: { $0.id == savedCompanyId })
            } else {
                print("Saved Company ID: 0, selecting first option")
                self.selectedCompany = userCompanies[0]
            }
            populateDataSource(companies: userCompanies, animated: true)
        }
    }
    
    enum Section { case main }
    var diffableDataSource: UITableViewDiffableDataSource<Section, UserCompaniesCodable>!
    
    
    // MARK: Init
    override func loadView() {
        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SELECT COMPANY"
        view.backgroundColor = .telaGray1
        configureNavigationBarAppearance()
        setupTargetActions()
        setupTableView()
        fetchUserCompanies()
    }
}


