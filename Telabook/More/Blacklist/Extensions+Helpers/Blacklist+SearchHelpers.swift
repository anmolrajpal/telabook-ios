//
//  Blacklist+SearchHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 21/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension BlacklistViewController {
    
    /// Setup the `UISearchController` to let users search through the list of colors
    internal func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search Blacklist"
        searchController.searchBar.barStyle = .black
        searchController.searchBar.isTranslucent = true
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.keyboardType = .phonePad
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        let attributes:[NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor : UIColor.telaRed,
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}
extension BlacklistViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        currentSearchText = text
        setupFetchedResultsController()
    }
}
