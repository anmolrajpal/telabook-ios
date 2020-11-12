//
//  CallViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 01/11/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import linphonesw


//extension Call: Equatable {
//    public static func == (lhs: Call, rhs: Call) -> Bool {
//        return lhs.
//    }
//}



protocol CallViewDelegate {
    func didDeclineIncomingCall(call: Call)
    func callAborted(call: Call)
}

class CallViewController: UIViewController {
    
    // MARK: - Declarations
    let call: Call
    var isVideoHidden = true
    var isCallRecordingEnabled = false
    var center: CGPoint! //center of the CS
//    var shouldDismiss = false // Not in use anymore
//    var maxLengthToCenter: CGFloat! //maximum distance from the center of the CS to the furthest point in the CS => // Not in use anymore
    
    var delegate: CallViewDelegate?
    
    // MARK: - Init / deinit
    
    init(call: Call) {
        self.call = call
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("### \(self) - Deinitialized")
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        let appName:String = try! Configuration.value(for: .bundleDisplayName)
        callDescriptionLabel.text = "\(appName) Audio..."
        callerIdLabel.text = call.remoteAddress?.displayName ?? "Unknown"
//        showIncomingCallViews(animated: false)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutButtons()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CallManager.instance().nextCallIsTransfer = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateCallNotification(_:)), name: .linphoneCallUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleBluetoothAvailabilityNotification(_:)), name: .linphoneBluetoothAvailabilityUpdate, object: nil)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCallDuration), userInfo: nil, repeats: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        UIDevice.current.isProximityMonitoringEnabled = true
        
        let state = call.state
        didUpdateCall(call: call, state: state, animated: false)
        /*
        // we must wait didAppear to reset fullscreen mode because we cannot change it in viewwillappear
        if let call = linphoneCore.currentCall,
           call.getCobject == self.call.getCobject {
            let state = call.state
            didUpdateCall(call: call, state: state, animated: false)
        } else {
            fatalError("Current call and displayed call not same. It means unhandled case.")
        }
        */
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIDevice.current.isProximityMonitoringEnabled = false
        disableVideoDisplay(disabled: true, false)
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        UIDevice.current.isProximityMonitoringEnabled = false
        if linphoneCore.callsNb == 0 {
            // reseting speaker button because no more call
//            speakerButton.selected = false
        }
        
    }
    
    
    
    @objc
    func handleBluetoothAvailabilityNotification(_ notification: Notification) {
        guard let dictionary = notification.userInfo,
              let value = dictionary["available"] as? Bool else {
            return
        }
        let isAvailable = value
        DispatchQueue.main.async {
            self.handleCallViews(bluetoothAvailable: isAvailable)
        }
    }
    func handleCallViews(bluetoothAvailable: Bool) {
//        speakerButton.hidden = hidden
//        routesButton.hidden = !hidden
    }
    @objc
    func handleUpdateCallNotification(_ notification: Notification) {
        guard let dictionary = notification.userInfo,
              let callObject = dictionary["call"] as? Call,
              let stateValue = dictionary["state"] as? Int,
              let state = Call.State(rawValue: stateValue) else {
            fatalError()
        }
//        let call = Call.getSwiftObject(cObject: callObject)
        let call = callObject
        didUpdateCall(call: call, state: state, animated: true)
    }
    
    
    func updateCallView(call: Call, state: Call.State, animated: Bool) {
//        optionsButton.enabled = !linphoneCore.soundResourcesLocked()
//        optionsTransferButton.enabled = !linphoneCore.soundResourcesLocked()
        
        // enable conference button if 2 calls are presents and at least one is not in the conference
//        let confSize = linphoneCore.conferenceSize - (linphoneCore.isInConference ? 1 : 0)
//        optionsConferenceButton.enabled = linphoneCore.callsNb > 1 && linphoneCore.callsNb != confSize

        // Disable transfert in conference
//        if linphoneCore.currentCall == nil {
//            optionsTransferButton.setEnabled(false)
//        } else {
//            optionsTransferButton.setEnabled(true)
//        }
        
        
        switch state {
        case .IncomingReceived:
            showIncomingCallViews(animated: animated)
            hideConnectedCallViews(animated: animated)
        case .IncomingEarlyMedia:
            if linphoneCore.callsNb > 1 {
                print("Linphone Core Calls NB: \(linphoneCore.callsNb); Should display new call")
            }
        case .Connected, .StreamsRunning:
            print("Seems good; Call State: \(state)\tHiding Incoming Call View and Showing Connected Call Views")
            hideIncomingCallViews(animated: animated)
            showConnectedCallViews(animated: animated)
        case .End:
            dismissAnimated {
                self.delegate?.callAborted(call: call)
            }
        case .Error:
            delegate?.callAborted(call: call)
            break
        case .Released:
            if UIApplication.shared.applicationState == .background {
                dismissAnimated(animated: false) {
                    self.delegate?.callAborted(call: call)
                }
                CoreManager.instance().stopLinphoneCore()
            }
        case .Pausing, .Paused:
            print("Unhandled state : \(state)")
        case .PausedByRemote:
            fatalError("Paused by remote. > Unhandled case: \(state)")
        
        case .EarlyUpdatedByRemote, .UpdatedByRemote:
            fatalError("Call Updated by remote. Wondering what to do with this.")
        case .Idle:
            fatalError("No idea what to do with this state: \(state)")
        case .OutgoingInit:
            fatalError("Outgoing calls not supported.")
        case .OutgoingProgress:
            fatalError("Outgoing calls not supported.")
        case .OutgoingRinging:
            fatalError("Outgoing calls not supported.")
        case .OutgoingEarlyMedia:
            fatalError("Outgoing calls not supported.")
        case .Resuming:
            fatalError("No idea what to do with this state: \(state)")
        case .Referred:
            fatalError("No idea what to do with this state: \(state)")
        case .Updating:
            fatalError("No idea what to do with this state: \(state)")
        case .EarlyUpdating:
            fatalError("No idea what to do with this state: \(state)")
        }
        
    }
    
    
    
    
    
    func didUpdateCall(call: Call, state: Call.State, animated:Bool) {
        updateCallView(call: call, state: state, animated: animated)
        let currentCall = linphoneCore.currentCall
        // call onCurrentCallChange()
        
        let shouldDisableVideo = !(currentCall?.currentParams?.videoEnabled == true)
        if isVideoHidden != shouldDisableVideo {
            if !shouldDisableVideo {
                displayVideoCall(animated)
            } else {
                displayAudioCall(animated)
            }
        }
        
        // camera is diabled during conference, it must be activated after leaving conference.
        if !shouldDisableVideo && !linphoneCore.isInConference {
            call.cameraEnabled = true
        }
        // call updateCallView()
        
        if state != .PausedByRemote {
            // pausedByRemoteView.isHidden = true
        }
        
        switch state {
        case .IncomingReceived,
             .OutgoingInit,
             .Connected,
             .StreamsRunning:
            // check video, because video can be disabled because of the low bandwidth.
            if let currentParams = call.currentParams,
               !currentParams.videoEnabled,
                let appData = CallManager.getAppData(sCall: call) {
                if state == .StreamsRunning && appData.videoRequested && currentParams.lowBandwidthEnabled {
                    // too bad video was not enabled because low bandwidth
                    DispatchQueue.main.async {
                        UIAlertController.showTelaAlert(title: "Low Bandwidth", message: "Video cannot be activated because of low bandwidth", controller: self)
                    }
                    appData.videoRequested = false
                    CallManager.setAppData(sCall: call, appData: appData)
                }
            }
            break
        case .UpdatedByRemote:
            guard let currentParams = call.currentParams,
                  let remoteParamas = call.remoteParams else {
                return
            }
        /* remote wants to add video */
            
            if (linphoneCore.videoDisplayEnabled && !currentParams.videoEnabled && remoteParamas.videoEnabled) &&
                (linphoneCore.videoActivationPolicy?.automaticallyAccept == false ||
                    ((UIApplication.shared.applicationState != UIApplication.State.active))) {
                do {
                    try call.deferUpdate()
                } catch {
                    print("Failed to defer call update: \(error)")
                }
//                self.displayAskToEnableVideoCall(call)
            } else if (currentParams.videoEnabled && !remoteParamas.videoEnabled) {
                displayAudioCall(animated)
            }
            break
        case .Pausing,
             .Paused:
            displayAudioCall(animated)
            break
        case .PausedByRemote:
            displayAudioCall(animated)
//            if call == linphoneCore.currentCall! {
//                pausedByRemoteView.hidden = false
//                updateInfoView(pausedByRemote: true)
//            }
        case .End,
             .Error: break
        default: break
        }
        
    }
    
    
    
    func displayVideoCall(_ animated:Bool) {
        disableVideoDisplay(disabled: false, animated)
    }
    func displayAudioCall(_ animated:Bool) {
        disableVideoDisplay(disabled: true, animated)
    }
    func disableVideoDisplay(disabled:Bool, _ animated:Bool) {
        if disabled == isVideoHidden && animated {
            print("I can understand. It makes less sense, right? for audio calls")
            return
        }
        isVideoHidden = disabled
        print("It's a great struggle")
        if !disabled {
//            videoZoomHandler.resetZoom()
        }
        
    }
    
    
    
    // MARK: - View Constructors
    
    lazy var backgroundImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "ios_wallpaper")
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var blurredEffectView:UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    lazy var backButton:UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = SFSymbol.chevron·down.image(withSymbolConfiguration: .init(pointSize: 24, weight: .semibold))
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.clipsToBounds = true
        return button
    }()
    lazy var logoImageView:UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = #imageLiteral(resourceName: "logo_transparent")
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var callerIdLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 26)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    lazy var callDescriptionLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    lazy var acceptButton:UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .systemGreen
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = SFSymbol.phone·fill.image(withSymbolConfiguration: .init(textStyle: .title1))
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.clipsToBounds = true
        button.isEnabled = false
        return button
    }()
    lazy var declineButton:UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemRed
        let image = SFSymbol.multiply.image(withSymbolConfiguration: .init(textStyle: .title1))
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.clipsToBounds = true
        button.isEnabled = false
        return button
    }()
    lazy var acceptLabel:UILabel = {
        let label = UILabel()
        label.text = "Accept"
        label.textColor = UIColor.telaGray7
        label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.light)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    lazy var declineLabel:UILabel = {
        let label = UILabel()
        label.text = "Decline"
        label.textColor = UIColor.telaGray7
        label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.light)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    lazy var acceptCallContainerView: UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.4)
        view.clipsToBounds = true
        return view
    }()
    lazy var declineCallContainerView: UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor.systemRed.withAlphaComponent(0.4)
        view.clipsToBounds = true
        return view
    }()
    lazy var incomingCallStackView:UIStackView = {
        let view = UIStackView()
//        view.backgroundColor = UIColor.systemPink.withAlphaComponent(0.1)
        view.axis = NSLayoutConstraint.Axis.horizontal
        view.alignment = UIStackView.Alignment.center
        view.distribution = UIStackView.Distribution.fillEqually
        view.alpha = 0
        return view
    }()

    
    lazy var audioSourceButton:UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        let image = SFSymbol.speaker.image(withSymbolConfiguration: .init(textStyle: .title1))
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.clipsToBounds = true
        button.isEnabled = false
        return button
    }()
    lazy var keypadButton:UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        let image = SFSymbol.keypad.image(withSymbolConfiguration: .init(textStyle: .title1))
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.clipsToBounds = true
        button.isEnabled = false
        return button
    }()
    lazy var muteButton:UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        let image = SFSymbol.mute.image(withSymbolConfiguration: .init(textStyle: .title1))
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.clipsToBounds = true
        button.isEnabled = false
        return button
    }()
    lazy var hangupButton:UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemRed
        let angle = 3 * (Float.pi / 4)
        let image = SFSymbol.phone·fill.image(withSymbolConfiguration: .init(textStyle: UIFont.TextStyle.title1))
            .rotate(radians: angle)!
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.clipsToBounds = true
        button.alpha = 0
        button.isEnabled = false
        return button
    }()
    lazy var connectedCallStackView:UIStackView = {
        let view = UIStackView()
//        view.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
        view.axis = NSLayoutConstraint.Axis.horizontal
        view.alignment = UIStackView.Alignment.fill
        view.distribution = UIStackView.Distribution.fill
        view.spacing = 0
        view.alpha = 0
        return view
    }()
    
    
    
    
    
    
}


protocol PhoneMicrophoneButton {
    func microphoneDidTurnOn()
    func microphoneDidTurnOff()
    func onUpdate()
}
class MicrophoneButton: UIButton, PhoneMicrophoneButton {
    func microphoneDidTurnOn() {
        linphoneCore.micEnabled = true
    }
    
    func microphoneDidTurnOff() {
        linphoneCore.micEnabled = false
    }
    
    func onUpdate() {
        
    }
    
    
}
