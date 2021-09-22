//
//  ContactAddress+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 19/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit

extension ContactAddressViewController {
   func commonInit() {
      title = addressToUpdateIndex == nil ? "Create New Address" : "Update Address"
      view.backgroundColor = .telaGray1
      configureNavigationBarAppearance()
      configureNavigationBarItems()
//      configureHierarchy()
      configureTableView()
      configureDataSource()
      hideKeyboardWhenTappedAround(cancellingTouches: false)
   }
   private func configureNavigationBarItems() {
      let cancelButtonImage = SFSymbol.cancel.image(withSymbolConfiguration: .init(textStyle: .largeTitle)).image(scaledTo: .init(width: 28, height: 28))
      let cancelButton = UIBarButtonItem(image: cancelButtonImage, style: .plain, target: self, action: #selector(cancelButtonDidTap))
      cancelButton.tintColor = UIColor.white.withAlphaComponent(0.2)
      navigationItem.leftBarButtonItems = [cancelButton]
      
      let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonDidTap))
      saveButton.setTitleTextAttributes([
          .font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14)!,
          .foregroundColor: UIColor.telaBlue
      ], for: .normal)
      saveButton.setBackgroundVerticalPositionAdjustment(-10, for: .default)
      navigationItem.rightBarButtonItems = [saveButton]
   }
   @objc
   private func cancelButtonDidTap() {
      self.dismiss(animated: true)
   }
   @objc
   private func saveButtonDidTap() {
      validateDataAndProcess()
   }
   private func validateDataAndProcess() {
      guard let addressNameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell,
            let mainAddressCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? TextFieldTableViewCell
      else { fatalError() }
      
      guard !address.addressName.isBlank else {
         addressNameCell.animateBorderWidth(toValue: 1, duration: 0.3, withColor: .systemRed)
         addressNameCell.shake(withFeedbackTypeOf: .Heavy)
         DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            addressNameCell.animateBorderWidth(toValue: 0, duration: 0.3, withColor: .systemRed)
         }
         return
      }
      guard address.mainAddress != nil else {
         mainAddressCell.animateBorderWidth(toValue: 1, duration: 0.3, withColor: .systemRed)
         mainAddressCell.shake(withFeedbackTypeOf: .Heavy)
         DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            mainAddressCell.animateBorderWidth(toValue: 0, duration: 0.3, withColor: .systemRed)
         }
         return
      }
      guard !existingAddresses.contains(where: { $0.addressName == address.addressName }) else {
         addressNameCell.animateBorderWidth(toValue: 1, duration: 0.3, withColor: .systemRed)
         addressNameCell.shake(withFeedbackTypeOf: .Heavy)
         let message = "You already have an existing address with the same address name. Please enter a different value"
         let action = UIAlertAction(title: "Ok", style: .destructive) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
               addressNameCell.animateBorderWidth(toValue: 0, duration: 0.3, withColor: .systemRed)
            }
         }
         UIAlertController.showTelaAlert(title: "Error", message: message, action: action, controller: self)
         return
      }
      guard !existingAddresses.contains(where: { $0.mainAddress?.placeId == address.mainAddress?.placeId }) else {
         mainAddressCell.animateBorderWidth(toValue: 1, duration: 0.3, withColor: .systemRed)
         mainAddressCell.shake(withFeedbackTypeOf: .Heavy)
         let message = "You already have an existing address with the same address. Please enter a different value"
         let action = UIAlertAction(title: "Ok", style: .destructive) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
               mainAddressCell.animateBorderWidth(toValue: 0, duration: 0.3, withColor: .systemRed)
            }
         }
         UIAlertController.showTelaAlert(title: "Error", message: message, action: action, controller: self)
         return
      }
      delegate?.addressDidUpsert(address: address, controller: self)
      
   }
}
