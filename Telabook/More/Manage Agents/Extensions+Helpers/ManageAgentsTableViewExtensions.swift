//
//  ManageAgentsTableViewExtensions.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
extension ManageAgentsViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.filteredSearch.count
        } else {
            return self.agents?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ManageAgentsCell.self), for: indexPath) as! ManageAgentsCell
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.telaGray7.withAlphaComponent(0.2)
        cell.selectedBackgroundView  = backgroundView
        var agentItem:InternalConversationsCodable?
        if isSearching {
            agentItem = self.filteredSearch[indexPath.row]
        } else {
            agentItem = self.agents?[indexPath.row]
        }
        cell.agentDetails = agentItem
        return cell
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
            filteredSearch = agents?.filter({$0.personName?.range(of: searchBar.text!, options: String.CompareOptions.caseInsensitive) != nil}) ?? []
            tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ManageAgentsCell.cellHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let agentDetails = self.agents?[indexPath.row] {
            let agentDetailsVC = AgentDetailsViewController(agentDetails: agentDetails)
            navigationController?.pushViewController(agentDetailsVC, animated: true)
        }
    }
}
