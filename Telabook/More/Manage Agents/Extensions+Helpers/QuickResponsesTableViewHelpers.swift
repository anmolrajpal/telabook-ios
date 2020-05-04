//
//  QuickResponsesTableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit


extension QuickResponsesViewController {
    internal func setupTableView() {
        subview.tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        subview.tableView.delegate = self
        subview.tableView.dataSource = self
    }
}

extension QuickResponsesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction =  UIContextualAction(style: .normal, title: "Edit", handler: { (action,view,completion ) in
            if let quickResponse = self.quickResponses?[indexPath.row],
                let responseId = quickResponse.id,
                let response = quickResponse.answer,
                responseId != 0,
                !response.isEmpty {
                self.showEditResponseDialogBox(responseId: String(responseId), response: response)
                completion(true)
            } else {
                fatalError("Error unwrapping quick response values")
            }
        })
        editAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "edit"), text: "Edit").withRenderingMode(.alwaysOriginal)
        editAction.backgroundColor = UIColor.telaIndigo
        
        let deleteAction =  UIContextualAction(style: .destructive, title: "Delete", handler: { (action,view,completion ) in
            self.initiateDeleteQuickResponseSequence(at: indexPath, completion: completion)
            
        })
        deleteAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "delete_icon"), text: "Delete").withRenderingMode(.alwaysOriginal)
        deleteAction.backgroundColor = UIColor.telaRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
}
