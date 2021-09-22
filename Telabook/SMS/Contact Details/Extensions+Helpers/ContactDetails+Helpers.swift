//
//  ContactDetails+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit

extension ContactDetailsViewController {
   func commonInit() {
      title = "Contact Details"
      view.backgroundColor = .telaGray1
      configureNavigationBarAppearance()
      configureNavigationBarItems()
      hideKeyboardWhenTappedAround(cancellingTouches: false)
      configureTableView()
      configureDataSource()
      updateUI()
//      loadAddressesFromStore()
   }
   private func configureNavigationBarItems() {
      let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonDidTap))
      saveButton.setTitleTextAttributes([
         .font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14)!,
         .foregroundColor: UIColor.telaBlue
      ], for: .normal)
      saveButton.setTitleTextAttributes([
         .font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14)!,
         .foregroundColor: UIColor.telaBlue.withAlphaComponent(0.5)
      ], for: .highlighted)
      saveButton.setBackgroundVerticalPositionAdjustment(-10, for: .default)
      navigationItem.rightBarButtonItems = [saveButton]
   }
   @objc
   private func saveButtonDidTap() {
      updateContact()
   }
   func updateContact() {
      validateDataAndProcess()
   }
   func validateDataAndProcess() {
      view.endEditing(true)
      guard let contactNameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ContactDetailsTextFieldCell,
            let globalNameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ContactDetailsTextFieldCell,
            let phoneNumberCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? ContactDetailsTextFieldCell
      else { fatalError() }
      
      guard let contactName = contactNameCell.textField.text, !contactName.isBlank else {
         contactNameCell.animateBorderWidth(toValue: 1, duration: 0.3, withColor: .systemRed)
         contactNameCell.shake(withFeedbackTypeOf: .Heavy)
         DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            contactNameCell.animateBorderWidth(toValue: 0, duration: 0.3, withColor: .systemRed)
         }
         return
      }
      
      guard let globalName = globalNameCell.textField.text, !globalName.isBlank else {
         globalNameCell.animateBorderWidth(toValue: 1, duration: 0.3, withColor: .systemRed)
         globalNameCell.shake(withFeedbackTypeOf: .Heavy)
         DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            globalNameCell.animateBorderWidth(toValue: 0, duration: 0.3, withColor: .systemRed)
         }
         return
      }
      
      if isCreatingNewContact {
         let formattedNumber = phoneNumberCell.textField.text ?? ""
         let phoneNumber = formattedNumber.extractNumbers
         
         guard phoneNumber.isPhoneNumberLengthValid() else {
            phoneNumberCell.animateBorderWidth(toValue: 1, duration: 0.3, withColor: .systemRed)
            phoneNumberCell.shake(withFeedbackTypeOf: .Heavy)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
               phoneNumberCell.animateBorderWidth(toValue: 0, duration: 0.3, withColor: .systemRed)
            }
            return
         }
         let number = "+1\(phoneNumber)"
         
         createContact(workerId: agentMOC.workerID.toInt,
                       contactName: contactName,
                       contactGlobalName: globalName,
                       contactPhoneNumber: number,
                       addresses: contact.address!,
                       isFavourited: contact.priority.boolValue)
      } else {
         updateContactDetails(contactConversationId: contact.contactConversationId!,
                              contactName: contactName,
                              contactGlobalName: globalName,
                              addresses: contact.address!,
                              isFavourited: contact.priority.boolValue)
      }
   }
   
   /* ------------------------------------------------------------------------------------------------------------ */
   private func updateContactDetails(contactConversationId: Int,
                                     contactName: String,
                                     contactGlobalName: String,
                                     addresses: [AddressBookProperties.Address],
                                     isFavourited: Bool) {
      TapticEngine.generateFeedback(ofType: .Medium)
      UIAlertController.showModalSpinner(with: "Saving...", controller: topMostViewController())
      let headers:[HTTPHeader] = [
         HTTPHeader(key: .contentType, value: Header.contentType.json.rawValue)
      ]
      let params: [String: String] = [
         "company_id": String(AppData.companyId)
      ]
      struct Body: Encodable {
         let contact_name: String
         let contact_global_name: String
         let address: [AddressBookProperties.Address]
         let priority: Int
      }
      let body = Body(contact_name: contactName, contact_global_name: contactGlobalName, address: addresses, priority: isFavourited.intValue)
      let encoder = JSONEncoder.apiServiceEncoder
      let httpBody = try! encoder.encode(body)
      
      APIServer<UpdateContactJSONResponse>(apiVersion: .v2)
         .hitEndpoint(endpoint: .UpdateContactDetails(contactConversationID: contactConversationId),
                      httpMethod: .PUT,
                      params: params,
                      httpBody: httpBody,
                      headers: headers,
                      completion: contactDetailsUpdateCompletion)
   }
   /* ------------------------------------------------------------------------------------------------------------ */
   
   
   private func contactDetailsUpdateCompletion(result: Result<UpdateContactJSONResponse, APIService.APIError>) {
      switch result {
      case .failure(let error):
         DispatchQueue.main.async {
            UIAlertController.dismissModalSpinner(controller: self) {
               UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription, controller: self)
               TapticEngine.generateFeedback(ofType: .Error)
            }
         }
      case .success(let resultData):
         switch resultData.result {
         case .failure:
            let errorMessage = "Failed to update addressbook contact details"
            DispatchQueue.main.async {
               UIAlertController.dismissModalSpinner(controller: self) {
                  UIAlertController.showTelaAlert(title: "Error", message: resultData.message ?? errorMessage, controller: self)
                  TapticEngine.generateFeedback(ofType: .Error)
               }
            }
         case .success:
            DispatchQueue.main.async {
               UIAlertController.dismissModalSpinner(controller: self) {
                  TapticEngine.generateFeedback(ofType: .Success)
                  AssertionModalController(title: "Updated").show() {
                     self.navigationController?.popViewController(animated: true)
                  }
               }
            }
         }
      }
   }
   
   
   /* ------------------------------------------------------------------------------------------------------------ */
   private func createContact(workerId: Int,
                              contactName: String,
                              contactGlobalName: String,
                              contactPhoneNumber: String,
                              addresses: [AddressBookProperties.Address],
                              isFavourited: Bool) {
      TapticEngine.generateFeedback(ofType: .Medium)
      UIAlertController.showModalSpinner(with: "Saving...", controller: topMostViewController())
      let headers:[HTTPHeader] = [
         HTTPHeader(key: .contentType, value: Header.contentType.json.rawValue)
      ]
      let params: [String: String] = [
         "company_id": String(AppData.companyId)
      ]
      struct Body: Encodable {
         let worker_id: Int
         let contact_name: String
         let contact_global_name: String
         let contact_phone_number: String
         let address: [AddressBookProperties.Address]
         let priority: Int
      }
      let body = Body(worker_id: workerId,
                      contact_name: contactName,
                      contact_global_name: contactGlobalName,
                      contact_phone_number: contactPhoneNumber,
                      address: addresses,
                      priority: isFavourited.intValue)
      let encoder = JSONEncoder.apiServiceEncoder
      let httpBody = try! encoder.encode(body)
      
      APIServer<UpdateContactJSONResponse>(apiVersion: .v2)
         .hitEndpoint(endpoint: .CreateAddressBookContact,
                      httpMethod: .POST,
                      params: params,
                      httpBody: httpBody,
                      headers: headers,
                      completion: contactDetailsUpdateCompletion)
   }
   /* ------------------------------------------------------------------------------------------------------------ */
}
