//
//  SMSDetailVCChatExtensions.swift
//  Telabook
//
//  Created by Anmol Rajpal on 14/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
import MessageKit
import MessageInputBar

extension SMSDetailViewController {
    
    // MARK: - Register / Unregister Observers
    
    internal func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(SMSDetailViewController.handleKeyboardDidChangeState(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SMSDetailViewController.handleTextViewDidBeginEditing(_:)), name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SMSDetailViewController.adjustScrollViewTopInset), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    internal func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // MARK: - Notification Handlers
    
    @objc
    private func handleTextViewDidBeginEditing(_ notification: Notification) {
        if scrollsToBottomOnKeyboardBeginsEditing {
            guard let inputTextView = notification.object as? InputTextView, inputTextView === messageInputBar.inputTextView else { return }
            messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    @objc
    private func handleKeyboardDidChangeState(_ notification: Notification) {
        guard !isMessagesControllerBeingDismissed else { return }
        
        guard let keyboardStartFrameInScreenCoords = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect else { return }
        guard !keyboardStartFrameInScreenCoords.isEmpty else {
            // WORKAROUND for what seems to be a bug in iPad's keyboard handling in iOS 11: we receive an extra spurious frame change
            // notification when undocking the keyboard, with a zero starting frame and an incorrect end frame. The workaround is to
            // ignore this notification.
            return
        }
        
        // Note that the check above does not exclude all notifications from an undocked keyboard, only the weird ones.
        //
        // We've tried following Apple's recommended approach of tracking UIKeyboardWillShow / UIKeyboardDidHide and ignoring frame
        // change notifications while the keyboard is hidden or undocked (undocked keyboard is considered hidden by those events).
        // Unfortunately, we do care about the difference between hidden and undocked, because we have an input bar which is at the
        // bottom when the keyboard is hidden, and is tied to the keyboard when it's undocked.
        //
        // If we follow what Apple recommends and ignore notifications while the keyboard is hidden/undocked, we get an extra inset
        // at the bottom when the undocked keyboard is visible (the inset that tries to compensate for the missing input bar).
        // (Alternatives like setting newBottomInset to 0 or to the height of the input bar don't work either.)
        //
        // We could make it work by adding extra checks for the state of the keyboard and compensating accordingly, but it seems easier
        // to simply check whether the current keyboard frame, whatever it is (even when undocked), covers the bottom of the collection
        // view.
        
        guard let keyboardEndFrameInScreenCoords = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardEndFrame = view.convert(keyboardEndFrameInScreenCoords, from: view.window)
        
        let newBottomInset = requiredScrollViewBottomInset(forKeyboardFrame: keyboardEndFrame)
        let differenceOfBottomInset = newBottomInset - messageCollectionViewBottomInset
        
        if maintainPositionOnKeyboardFrameChanged && differenceOfBottomInset != 0 {
            let contentOffset = CGPoint(x: messagesCollectionView.contentOffset.x, y: messagesCollectionView.contentOffset.y + differenceOfBottomInset)
            messagesCollectionView.setContentOffset(contentOffset, animated: false)
        }
        
        messageCollectionViewBottomInset = newBottomInset
    }
    
    // MARK: - Inset Computation
    
    @objc
    internal func adjustScrollViewTopInset() {
        if #available(iOS 11.0, *) {
            // No need to add to the top contentInset
        } else {
            let navigationBarInset = navigationController?.navigationBar.frame.height ?? 0
            let statusBarInset: CGFloat = UIApplication.shared.isStatusBarHidden ? 0 : 20
            let topInset = navigationBarInset + statusBarInset
            messagesCollectionView.contentInset.top = topInset
            messagesCollectionView.scrollIndicatorInsets.top = topInset
        }
    }
    
    private func requiredScrollViewBottomInset(forKeyboardFrame keyboardFrame: CGRect) -> CGFloat {
        // we only need to adjust for the part of the keyboard that covers (i.e. intersects) our collection view;
        // see https://developer.apple.com/videos/play/wwdc2017/242/ for more details
        let intersection = messagesCollectionView.frame.intersection(keyboardFrame)
        
        if intersection.isNull || intersection.maxY < messagesCollectionView.frame.maxY {
            // The keyboard is hidden, is a hardware one, or is undocked and does not cover the bottom of the collection view.
            // Note: intersection.maxY may be less than messagesCollectionView.frame.maxY when dealing with undocked keyboards.
            return max(0, additionalBottomInset - automaticallyAddedBottomInset)
        } else {
            return max(0, intersection.height + additionalBottomInset - automaticallyAddedBottomInset)
        }
    }
    
    internal func requiredInitialScrollViewBottomInset() -> CGFloat {
        guard let inputAccessoryView = inputAccessoryView else { return 0 }
        return max(0, inputAccessoryView.frame.height + additionalBottomInset - automaticallyAddedBottomInset)
    }
    
    /// iOS 11's UIScrollView can automatically add safe area insets to its contentInset,
    /// which needs to be accounted for when setting the contentInset based on screen coordinates.
    ///
    /// - Returns: The distance automatically added to contentInset.bottom, if any.
    private var automaticallyAddedBottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            return messagesCollectionView.adjustedContentInset.bottom - messagesCollectionView.contentInset.bottom
        } else {
            return 0
        }
    }
    
    // MARK: - Register / Unregister Observers
    
    internal func addMenuControllerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(SMSDetailViewController.menuControllerWillShow(_:)), name: UIMenuController.willShowMenuNotification, object: nil)
    }
    
    internal func removeMenuControllerObservers() {
        NotificationCenter.default.removeObserver(self, name: UIMenuController.willShowMenuNotification, object: nil)
    }
    
    // MARK: - Notification Handlers
    
    /// Show menuController and set target rect to selected bubble
    @objc
    private func menuControllerWillShow(_ notification: Notification) {
        
        guard let currentMenuController = notification.object as? UIMenuController,
            let selectedIndexPath = selectedIndexPathForMenu else { return }
        
        NotificationCenter.default.removeObserver(self, name: UIMenuController.willShowMenuNotification, object: nil)
        defer {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(SMSDetailViewController.menuControllerWillShow(_:)),
                                                   name: UIMenuController.willShowMenuNotification, object: nil)
            selectedIndexPathForMenu = nil
        }
        
        currentMenuController.setMenuVisible(false, animated: false)
        
        guard let selectedCell = messagesCollectionView.cellForItem(at: selectedIndexPath) as? MessageContentCell else { return }
        let selectedCellMessageBubbleFrame = selectedCell.convert(selectedCell.messageContainerView.frame, to: view)
        
        var messageInputBarFrame: CGRect = .zero
        if let messageInputBarSuperview = messageInputBar.superview {
            messageInputBarFrame = view.convert(messageInputBar.frame, from: messageInputBarSuperview)
        }
        
        var topNavigationBarFrame: CGRect = navigationBarFrame
        if navigationBarFrame != .zero, let navigationBarSuperview = navigationController?.navigationBar.superview {
            topNavigationBarFrame = view.convert(navigationController!.navigationBar.frame, from: navigationBarSuperview)
        }
        
        let menuHeight = currentMenuController.menuFrame.height
        
        let selectedCellMessageBubblePlusMenuFrame = CGRect(x: selectedCellMessageBubbleFrame.origin.x, y: selectedCellMessageBubbleFrame.origin.y - menuHeight, width: selectedCellMessageBubbleFrame.size.width, height: selectedCellMessageBubbleFrame.size.height + 2 * menuHeight)
        
        var targetRect: CGRect = selectedCellMessageBubbleFrame
        currentMenuController.arrowDirection = .default
        
        /// Message bubble intersects with navigationBar and keyboard
        if selectedCellMessageBubblePlusMenuFrame.intersects(topNavigationBarFrame) && selectedCellMessageBubblePlusMenuFrame.intersects(messageInputBarFrame) {
            let centerY = (selectedCellMessageBubblePlusMenuFrame.intersection(messageInputBarFrame).minY + selectedCellMessageBubblePlusMenuFrame.intersection(topNavigationBarFrame).maxY) / 2
            targetRect = CGRect(x: selectedCellMessageBubblePlusMenuFrame.midX, y: centerY, width: 1, height: 1)
        } /// Message bubble only intersects with navigationBar
        else if selectedCellMessageBubblePlusMenuFrame.intersects(topNavigationBarFrame) {
            currentMenuController.arrowDirection = .up
        }
        currentMenuController.setTargetRect(targetRect, in: view)
        currentMenuController.setMenuVisible(true, animated: true)
    }
   
    // MARK: - Helpers
    
    private var navigationBarFrame: CGRect {
        guard let navigationController = navigationController, !navigationController.navigationBar.isHidden else {
            return .zero
        }
        return navigationController.navigationBar.frame
    }
}




