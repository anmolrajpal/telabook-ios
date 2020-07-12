//
//  MediaAssertionController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 10/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

protocol MediaAssertionDelegate {
    func mediaAssertionController(controller: UIViewController, didPickImage image:UIImage, textMessage:String)
    func mediaAssertionController(controller: UIViewController, didFinishCancelled cancelled:Bool)
}

class MediaAssertionController: UIViewController {
    
    // MARK: - Properties
    
    var delegate:MediaAssertionDelegate?
    
    var isControllerBeingDismissed:Bool = false
    
    var maintainPositionOnKeyboardFrameChanged: Bool = false
    
    private var isFirstLayout: Bool = true
    
    internal var mediaViewBottomInset: CGFloat = 0 {
        didSet {
            mediaView.contentInset.bottom = mediaViewBottomInset
            mediaView.verticalScrollIndicatorInsets.bottom = mediaViewBottomInset
        }
    }
    var additionalBottomInset: CGFloat = 0 {
        didSet {
            let delta = additionalBottomInset - oldValue
            mediaViewBottomInset += delta
        }
    }
    
    
    
    
    
    // MARK: - Init
    
    let image:UIImage
    
    required init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        removeKeyboardObservers()
    }
    
    
    
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationController?.navigationBar.isHidden = true
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var inputAccessoryView: UIView? {
        return messageInputBar
    }

    override var shouldAutorotate: Bool {
        return false
    }
    override func viewDidLayoutSubviews() {
        // Hack to prevent animation of the contentInset after viewDidAppear
        if isFirstLayout {
            defer { isFirstLayout = false }
            addKeyboardObservers()
            mediaViewBottomInset = requiredInitialScrollViewBottomInset()
        }
        adjustScrollViewTopInset()
    }

    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
        }
        mediaViewBottomInset = requiredInitialScrollViewBottomInset()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isControllerBeingDismissed = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isControllerBeingDismissed = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isControllerBeingDismissed = false
    }
    
    
    
    
    
    
    // MARK: - View Constructors
    
    lazy var messageInputBar = InputBarAccessoryView()
    
    lazy var mediaView = ImageZoomView()
    
    lazy var blurredEffectView:UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var vibrancyEffectView:UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let view = UIVisualEffectView(effect: vibrancyEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    
    // MARK: - Methods
    
    private func commonInit() {
        configureHierarchy()
        configureMediaView()
        configureMessageInputBar()
    }
    private func configureHierarchy() {
        blurredEffectView.contentView.addSubview(vibrancyEffectView)
        view.addSubview(blurredEffectView)
        view.addSubview(mediaView)
        layoutConstraints()
    }
    private func configureMediaView() {
        mediaView.image = image
        mediaView.keyboardDismissMode = .interactive
        mediaView.alwaysBounceVertical = true
        mediaView.alwaysBounceHorizontal = true
    }
    var bottomConstraint:NSLayoutConstraint!
    private func layoutConstraints() {
        blurredEffectView.fillSuperview()
        vibrancyEffectView.anchor(top: blurredEffectView.topAnchor, left: blurredEffectView.leftAnchor, bottom: blurredEffectView.bottomAnchor, right: blurredEffectView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        mediaView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
   
    @objc
    private func cancelButtonDidTap(_ sender:UIButton) {
        delegate?.mediaAssertionController(controller: self, didFinishCancelled: true)
    }
    internal func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.shouldManageSendButtonEnabledState = false
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.textColor = .telaWhite
        messageInputBar.backgroundView.backgroundColor = UIColor.telaGray1
        messageInputBar.contentView.backgroundColor = UIColor.telaGray1
        messageInputBar.inputTextView.backgroundColor = UIColor.telaGray5
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 36)
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.inputTextView.keyboardAppearance = UIKeyboardAppearance.dark
        messageInputBar.inputTextView.layer.borderWidth = 0
        messageInputBar.inputTextView.layer.cornerRadius = 20.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        configureMessageInputBarItems()
    }
    private func configureMessageInputBarItems() {
        messageInputBar.sendButton.setImage(#imageLiteral(resourceName: "autoresponse_icon"), for: .normal)
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.isEnabled = true
        messageInputBar.sendButton.setSize(CGSize(width: 32, height: 32), animated: false)
        messageInputBar.rightStackView.alignment = .center
        
        let cancelButton = makeButton(image: SFSymbol.cancel.image(withSymbolConfiguration: .init(textStyle: .title1))) {
            self.delegate?.mediaAssertionController(controller: self, didFinishCancelled: true)
        }
        let leftStackButtons = [cancelButton]
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems(leftStackButtons, forStack: .left, animated: false)
    }
    private func makeButton(image:UIImage, actionCompletionHandler: @escaping (() -> Void)) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = image.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 32, height: 32), animated: false)
                $0.tintColor = UIColor(white: 0.6, alpha: 1)
            }.onSelected {
                $0.tintColor = .telaGray6
            }.onDeselected {
                $0.tintColor = UIColor(white: 0.6, alpha: 1)
            }.onTouchUpInside { _ in
                actionCompletionHandler()
            }
    }
}


extension MediaAssertionController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.mediaAssertionController(controller: self, didPickImage: self.image, textMessage: trimmedText)
                self.messageInputBar.inputTextView.placeholder = "Aa"
            }
        }
    }
}
