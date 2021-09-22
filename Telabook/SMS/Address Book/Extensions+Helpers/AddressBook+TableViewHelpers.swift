//
//  AddressBook+TableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData
extension AddressBookViewController {
   typealias SectionType = Section
   typealias ItemType = AddressBookContact
   typealias Snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>
   
   class Section: Hashable {
      var identifier = UUID()
      
      var title: String {
         return contacts.first?.firstLetter ?? "#"
      }
      
      var contacts: [ItemType]
      
      init(contacts: [ItemType]) {
         self.contacts = contacts
      }
      
      func hash(into hasher: inout Hasher) {
          hasher.combine(identifier)
      }
      static func == (lhs: Section, rhs: Section) -> Bool {
         lhs.identifier == rhs.identifier
      }
   }
   
   class DataSource: UITableViewDiffableDataSource<SectionType, ItemType> {
      let sectionTitles = (Constants.alphabet.uppercased() + "#").map(String.init)
      
      override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         snapshot().sectionIdentifiers[section].title
      }
      override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
         sectionTitles
      }
      override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
         index
      }
   }
   
   internal func configureTableView() {
      tableView.tableFooterView = tableFooterView
      tableView.refreshControl = tableViewRefreshControl
      tableView.register(AddressBookContactCell.self)
      tableView.delegate = self
      tableView.sectionIndexColor = .telaBlue
   }
   
   internal func configureDataSource() {
      dataSource = DataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, contact) -> UITableViewCell? in
         guard self != nil else { return nil }
         let cell = tableView.dequeueReusableCell(AddressBookContactCell.self, for: indexPath)
         cell.backgroundColor = .clear
         cell.configureCell(with: contact, animated: false)
         return cell
      })
      dataSource.defaultRowAnimation = .none
   }
   /*
   func currentSnapshot() -> Snapshot {
       guard dataSource != nil else {
           fatalError("### \(#function) Datasource not initialized")
       }
       return dataSource.snapshot()
   }
   func initialSnapshot() -> Snapshot {
       var snapshot = Snapshot()
       snapshot.appendSections(sections)
       sections.forEach { section in
           snapshot.appendItems(section.contacts, toSection: section)
       }
       return snapshot
   }
   */
   func currentSnapshot() -> Snapshot? {
      guard fetchedResultsController != nil else { return nil }
      var snapshot = Snapshot()
      let favouritedContacts = contacts.filter({ $0.isFavourited })
      let unfavouritedContacts = contacts.filter({ !favouritedContacts.contains($0) })
      let unsanitizedContacts = unfavouritedContacts.filter({ $0.firstLetter == "#" })
      let sanitizedContacts = unfavouritedContacts.filter({ !unsanitizedContacts.contains($0) })
      let alphabet = (Constants.alphabet.uppercased()).map(String.init)
      
      let favouritedSection = Section(contacts: favouritedContacts)
      let unsanitizedSection = Section(contacts: unsanitizedContacts)
      var sanitizedSections = [Section]()
      alphabet.forEach { letter in
         let contacts = sanitizedContacts.filter({ $0.firstLetter == letter })
         let section = Section(contacts: contacts)
         sanitizedSections.append(section)
      }
      
      var sections = [favouritedSection]
      sections.append(contentsOf: sanitizedSections)
      sections.append(unsanitizedSection)
      
      snapshot.appendSections(sections)
      sections.forEach { section in
         snapshot.appendItems(section.contacts, toSection: section)
      }
      
      /*
      sections.forEach { section in
         
         if section.title != "#" {
            snapshot.appendSections([section])
            snapshot.appendItems(section.contacts)
         }
      }
      if let section = sections.first(where: { $0.title == "#" }) {
         snapshot.deleteSections([section])
         snapshot.appendSections([section])
         snapshot.appendItems(section.contacts)
      }
      */
      return snapshot
   }
   func updateUI(animating:Bool = true, reloadingData:Bool = false) {
      guard let snapshot = currentSnapshot(), dataSource != nil else { return }
      dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
         guard let self = self else { return }
         self.configureTableFooterView()
         if reloadingData && self.viewDidAppear { self.tableView.reloadData() }
         if !self.isDownloading {
            self.handleState()
            self.stopRefreshers()
         }
      })
   }
   private func configureTableFooterView() {
      tableFooterView.frame = CGRect(origin: tableView.tableFooterView!.frame.origin, size: CGSize(width: tableView.frame.width, height: tableFooterView.viewHeight))
      let count = contacts.count
      if count > 0 {
         let text = count == 1 ? "1 Contact" : "\(count) Contacts"
         tableFooterView.contactsLabel.text = text
         tableFooterView.isHidden = false
      } else {
         tableFooterView.isHidden = true
      }
   }
}

// MARK: - UITableViewDelegate methods

extension AddressBookViewController {
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      AddressBookContactCell.cellHeight
   }
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      guard let selectedContact = dataSource.itemIdentifier(for: indexPath) else { return }
      let vc = ContactDetailsViewController()
      vc.contact = selectedContact.serverObject
      vc.agentMOC = selectedContact.agent
      vc.isCreatingNewContact = false
      navigationController?.pushViewController(vc, animated: true)
      viewDidAppear = false
   }
   override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      if section == 0 {
         guard let contact = dataSource.itemIdentifier(for: IndexPath(row: 0, section: 0)) else { return nil }
         if contact.isFavourited {
            let headerView = UIView()
            headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40)
            headerView.backgroundColor = .telaGray1
            let label = UILabel()
            let height = headerView.frame.height - 10
            let y = (headerView.frame.height - height) / 2
            label.frame = CGRect(x: 20, y: y, width: headerView.frame.width - 40, height: height)
            label.text = "Favorites"
            label.textColor = .telaBlue
            label.textAlignment = .left
            label.font = UIFont.gothamMedium(forTextStyle: .headline)
            headerView.addSubview(label)
            return headerView
         }
         return nil
      } else {
         return nil
      }
   }
   override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      if section == 0 {
         guard let contact = dataSource.itemIdentifier(for: IndexPath(row: 0, section: 0)) else { return 0 }
         return contact.isFavourited ? 40 : 0
      } else {
         guard dataSource.itemIdentifier(for: IndexPath(row: 0, section: section)) != nil else { return 0 }
         return 20
      }
   }
   
   override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
      if section == 0 {
         let footerView = UIView()
         footerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40)
         let label = UILabel()
         let height = footerView.frame.height - 10
         let y = (footerView.frame.height - height) / 2
         label.frame = CGRect(x: 20, y: y, width: footerView.frame.width - 40, height: height)
         label.text = "Contacts"
         label.textColor = .telaBlue
         label.textAlignment = .left
         label.font = UIFont.gothamMedium(forTextStyle: .headline)
         footerView.addSubview(label)
         
         return footerView
      }
      return nil
   }
   override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
      return section == 0 && !contacts.filter({ !$0.isFavourited }).isEmpty ? 40 : 0
   }
}
class ContactsFooterView: UIView {
   let viewHeight = CGFloat(100)
   
   // MARK: init
   required init?(coder: NSCoder) {
       super.init(coder: coder)
      configureHierarchy()
   }
   
   override init(frame: CGRect) {
       super.init(frame: frame)
      configureHierarchy()
   }
   override func layoutSubviews() {
       super.layoutSubviews()
       layoutConstraints()
   }
   
   private func configureHierarchy() {
      addSubview(contactsLabel)
   }
   private func layoutConstraints() {
      contactsLabel.centerInSuperview()
//      heightAnchor.constraint(equalToConstant: viewHeight).activate()
   }
   
   lazy var contactsLabel: UILabel = {
      let label = UILabel()
      label.numberOfLines = 1
      label.textAlignment = .center
      label.lineBreakMode = NSLineBreakMode.byTruncatingTail
      label.textColor = UIColor.telaGray7
      label.font = UIFont.systemFont(ofSize: 22)
      return label
   }()
}
