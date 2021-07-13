//
//  AddressBook+Search.swift
//  Telabook
//
//  Created by Anmol Rajpal on 10/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit

extension AddressBookViewController {
    /// Setup the `UISearchController` to let users search through the list of colors
    internal func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
//        searchController.searchBar.scopeButtonTitles = ["All", "Name", "Phone"]
//        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.barStyle = .black
        searchController.searchBar.isTranslucent = true
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        let attributes:[NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor : UIColor.telaRed,
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
}
extension AddressBookViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        currentSearchText = text
        configureFetchedResultsController()
    }
}
