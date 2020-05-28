//
//  BlockedUsersVCTableViewExtensions.swift
//  Telabook
//
//  Created by Anmol Rajpal on 22/06/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//
import UIKit
extension BlockedUsersViewController: UITableViewDataSource, UISearchBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.filteredSearch.count
        } else {
            return self.blacklist?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell?.selectionStyle = .none
        cell?.backgroundColor = .clear
        cell?.textLabel?.textColor = UIColor.telaWhite
        cell?.textLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
        cell?.detailTextLabel?.textColor = UIColor.telaGray7
        cell?.detailTextLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        var blackListItem:BlacklistCodable?
        if isSearching {
            blackListItem = self.filteredSearch[indexPath.row]
        } else {
            blackListItem = self.blacklist?[indexPath.row]
        }
        cell?.textLabel?.text = blackListItem?.number
        cell?.detailTextLabel?.text = blackListItem?.descriptionField
        return cell!
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        tableView.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchController.view.backgroundColor = UIColor.telaBlack.withAlphaComponent(0.6)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text?.count == 0 {
            searchController.view.backgroundColor = UIColor.telaBlack.withAlphaComponent(0.6)
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            searchController.view.backgroundColor = .clear
            isSearching = true
            filteredSearch = blacklist?.filter({$0.number?.range(of: searchBar.text!, options: String.CompareOptions.caseInsensitive) != nil}) ?? []
            tableView.reloadData()
        }
    }
    
}
extension BlockedUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let unblockAction =  UIContextualAction(style: .destructive, title: "Unblock", handler: { (action,view,completion ) in
            self.initiateUnblockNumberSequence(at: indexPath, completion: completion)
        })
        unblockAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "unblock"), text: "Unblock").withRenderingMode(.alwaysOriginal)
        unblockAction.backgroundColor = UIColor.telaIndigo
        let configuration = UISwipeActionsConfiguration(actions: [unblockAction])
        return configuration
    }
}
