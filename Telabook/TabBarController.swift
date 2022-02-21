//
//  TabBarController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
import Firebase
import linphonesw
import AVFoundation
import CoreTelephony


fileprivate extension UILabel {

    func startFlashing() {
        UIView.animate(withDuration: 0.8,
              delay:0.0,
              options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
              animations: { self.alpha = 0 },
              completion: nil)
    }

    func stopFlashing() {
        layer.removeAllAnimations()
        alpha = 1
    }
}
class TabBarController: UITabBarController {
    
    // MARK: - Declarations / Computed Properties
    
    var doubleHeightStatusBarHeightConstraint:NSLayoutConstraint!
    var currentCall: Call? = nil {
        didSet {
            updateCallBannerViewState()
        }
    }
    var isCallBannerActivated:Bool {
        guard doubleHeightStatusBarHeightConstraint != nil else { return false }
        return doubleHeightStatusBarHeightConstraint.constant > 0
    }
    var shouldShowCallBanner: Bool {
        return currentCall != nil
    }
    
    let callBannerPlaceholderText = "Touch to return to call • "
    
    
    func updateCallBannerViewState() {
        if currentCall != nil {
            if !isCallBannerActivated {
                enableCallBanner(animated: true)
            }
        } else {
                disableCallBanner(animated: true)
                resetCallBannerDisplayText()
            }
    }
    
    
    
    enum Tabs: Int, Codable {
        case tab1, tab2, tab3
        
        private var tabName:String {
            switch self {
                case .tab1: return "SMS"
                case .tab2: return "CALLS"
                case .tab3: return "MORE"
            }
        }
        private var tabImage:UIImage {
            switch self {
                case .tab1: return #imageLiteral(resourceName: "tab_sms_inactive")
                case .tab2: return #imageLiteral(resourceName: "tab_call_inactive")
                case .tab3: return #imageLiteral(resourceName: "tab_more_inactive")
            }
        }
        private var tabSelelctedImage:UIImage {
            switch self {
                case .tab1: return #imageLiteral(resourceName: "tab_sms_active")
                case .tab2: return #imageLiteral(resourceName: "tab_call_active")
                case .tab3: return #imageLiteral(resourceName: "tab_more_active")
            }
        }
        var tabBarItem:UITabBarItem {
            UITabBarItem(title: tabName, image: tabImage, selectedImage: tabSelelctedImage)
        }
    }
    
   
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotificationObservers()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCallDuration), userInfo: nil, repeats: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationObservers()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        doubleHeightStatusBarTextLabel.stopFlashing()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureDoubleHeightStatusBarViewHierarchy()
    }
    
    override func didReceiveMemoryWarning() {
        print("Did Receive memory warning on \(self)")
    }
    
    
    @objc
    func updateCallDuration() {
        if let call = currentCall {
            let duration = call.duration
            if duration > 0 {
                let elapsedTime = Date.getElapsedTimeFormattedString(fromSecondsPassed: duration)
                setCallBanner(displayText: "\(callBannerPlaceholderText)\(elapsedTime)")
            }
        }
    }
    func resetCallBannerDisplayText() {
        setCallBanner(displayText: "\(callBannerPlaceholderText)0:00")
    }
    
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleOnCallUpdateNotification(_:)), name: .linphoneCallUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRegistrationUpdateNotification(_:)), name: .linphoneRegistrationUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOnGlobalStateChangedNotification(_:)), name: .linphoneGlobalStateUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForegroundNotification(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(handleBatteryLevelChangedNotification(_:)), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
    }
    private func removeNotificationObservers() {
//        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        UIDevice.current.isBatteryMonitoringEnabled = false
    }
    @objc
    func handleEnterForegroundNotification(_ notification: Notification) {
        doubleHeightStatusBarTextLabel.alpha = 1
        if isCallBannerActivated && currentCall != nil {
            doubleHeightStatusBarTextLabel.startFlashing()
        }
    }
    
    
    
    @objc
    private func handleBatteryLevelChangedNotification(_ notification: Notification) {
        let level = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState
        lpLog.debug(msg: "Battery state: \(batteryState) level: \(level)")
        if let call = linphoneCore.currentCall,
           let currentParams = call.currentParams,
           currentParams.videoEnabled,
           let data = CallManager.getAppData(sCall: call) {
            
            if batteryState == .unplugged {
                if level <= 0.2 && !data.batteryWarningShown {
                    lpLog.message(msg: "Battery Warning")
                    // Should show custom view here to notify user that battery is low and ask to stop video
                    data.batteryWarningShown = true
                }
            }
            if level > 0.2 {
                data.batteryWarningShown = false
            }
            CallManager.setAppData(sCall: call, appData: data)
        }
    }
    
    
    @objc
    private func handleRegistrationUpdateNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let stateValue = userInfo["state"] as? Int,
              let message = userInfo["message"] as? String,
              let state = RegistrationState(rawValue: stateValue) else {
            return
        }
        
        if state == .Failed && UIApplication.shared.applicationState == .active {
            DispatchQueue.main.async {
                UIAlertController.showTelaAlert(title: "Connection Failure", message: message.localized(), controller: self)
            }
        } else if state == .Ok {
            // Good to go
        }
    }
    
    
    @objc
    func handleOnGlobalStateChangedNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let stateValue = userInfo["state"] as? Int,
              let state = GlobalState(rawValue: stateValue) else {
            return
        }
        
        if state == .On && LinphoneManager.instance().wasRemoteProvisioned {
            guard linphoneCore.defaultProxyConfig == nil else {
                return
            }
        }
    }
    
    
    @objc
    func handleOnCallUpdateNotification(_ notification: Notification) {

        guard let userInfo = notification.userInfo,
              let callObject = userInfo["call"] as? Call,
              let stateValue = userInfo["state"] as? Int,
              let state = Call.State(rawValue: stateValue),
              let message = userInfo["message"] as? String else {
            fatalError()
        }
         
//        let call = Call.getSwiftObject(cObject: OpaquePointer(callObject))
//        let call = Call.getSwiftObject(cObject: callObject)
        let call = callObject

        
        switch state {
        case .IncomingReceived:
            currentCall = call
            displayIncomingCall(call: call)
            // We can use below in case we don't want to show in app call UI when app is in active state and, just use call kit notifications.
            /*
                if !CallManager.callKitEnabled() {
                    displayIncomingCall(call: call)
                }
            */
        case .IncomingEarlyMedia:
            if linphoneCore.callsNb > 1 {
                displayIncomingCall(call: call)
            }
        case .OutgoingInit:
                fatalError()
            
        case .PausedByRemote,
             .Connected:
            /*
                if !LinphoneManager.instance().isCTCallCenterExists {
                    /*only register CT call center CB for connected call*/
                    LinphoneManager.instance().setupGSMInteraction()
                    UIDevice.current.isProximityMonitoringEnabled = !(CallManager.instance().speakerEnabled || CallManager.instance().bluetoothEnabled)
                }
             */
            currentCall = call
                
        case .StreamsRunning:
            showCallView(withCall: call)
            currentCall = call
            
        case .UpdatedByRemote:
            if let currentParams = call.currentParams,
               let remoteParams = call.remoteParams,
               currentParams.videoEnabled,
               !remoteParams.videoEnabled {
                showCallView(withCall: call)
            }
                
        case .Error:
            displayCallError(forCall: call, message: message)
        case .End:
            break
            /*
            let calls = linphoneCore.calls
            if calls.isEmpty {
                if presentedViewController is CallViewController {
                    presentedViewController?.dismiss(animated: false)
                }
            } else {
                // should show call view controller
                if presentedViewController is CallViewController {
                    return
                }
                showCallView(withCall: call)
            }
            */
        case .Released:
            if UIApplication.shared.applicationState == .background {
                DispatchQueue.main.async { [self] in
                    if presentedViewController is CallViewController {
                        presentedViewController?.dismiss(animated: false)
                    }
                }
                    CoreManager.instance().stopLinphoneCore()
                }
        case .EarlyUpdatedByRemote,
            .EarlyUpdating,
            .Idle,
            .OutgoingEarlyMedia,
            .OutgoingProgress,
            .OutgoingRinging,
            .Paused,
            .Pausing,
            .Referred,
            .Resuming,
            .Updating:
                break
        }
        if state == .End || state == .Error || Int32(floor(NSFoundationVersionNumber)) <= NSFoundationVersionNumber_iOS_9_x_Max {
            updateApplicationBadgeNumber()
            currentCall = nil
        }
    }
    
    func updateApplicationBadgeNumber() {
        var count = 0
        count += linphoneCore.missedCallsCount
//        count += LinphoneManager.unreadMessageCount // Since not using Linphone Chat messaging
        count += linphoneCore.callsNb
        UIApplication.shared.applicationIconBadgeNumber = count
        tabBar.items![Tabs.tab2.rawValue].badgeValue = count > 0 ? "\(count)" : nil
    }
    
    
    func displayCallError(forCall call: Call, message: String) {
        let userName = call.remoteAddress?.username ?? "Unknown"
        
        var lMessage = String()
        var lTitle = String()

        // get default proxy
        let proxyCfg = linphoneCore.defaultProxyConfig
        if proxyCfg == nil {
            lMessage = "Please make sure your device is connected to the internet and double check your SIP account configuration in the settings.".localized()
        } else {
            lMessage = "Cannot call \(userName)"
        }
        
        switch call.reason {
        case .NotFound:
            lMessage = "\(userName) is not connected"
        case .Busy:
            lMessage = "\(userName) is busy."
        default:
            if !message.isEmpty {
                lMessage = "Reason was: \(message)"
            }
        }

        lTitle = "Call failed".localized()
        
        DispatchQueue.main.async {
            UIAlertController.showTelaAlert(title: lTitle, message: lMessage, controller: self)
        }
    }
    
    
    
    private func commonInit() {
        delegate = self
//        configureDoubleHeightStatusBarViewHierarchy()
        configureDoubleHeightStatusBar()
        authenticate()
    }
    
    
    
    
    // MARK: - View Constructors
    
    lazy var doubleHeightStatusBar:UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var doubleHeightStatusBarTextLabel:UILabel = {
        let label = UILabel()
        label.text = "\(callBannerPlaceholderText)0:00"
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .white
        return label
    }()
    
    
    
    func configureDoubleHeightStatusBarViewHierarchy() {
        doubleHeightStatusBar.addSubview(doubleHeightStatusBarTextLabel)
        doubleHeightStatusBarTextLabel.anchor(top: doubleHeightStatusBar.centerYAnchor, left: doubleHeightStatusBar.leftAnchor, bottom: doubleHeightStatusBar.bottomAnchor, right: doubleHeightStatusBar.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        /*
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        window?.addSubview(doubleHeightStatusBar)
        
        doubleHeightStatusBar.anchor(top: window?.topAnchor, left: window?.leftAnchor, bottom: nil, right: window?.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0)
        */
        view.superview?.addSubview(doubleHeightStatusBar)
        doubleHeightStatusBar.anchor(top: view.superview?.topAnchor, left: view.superview?.leftAnchor, bottom: nil, right: view.superview?.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0)
        
        doubleHeightStatusBarHeightConstraint = doubleHeightStatusBar.heightAnchor.constraint(equalToConstant: 0)
        doubleHeightStatusBarHeightConstraint.activate()
    }
    
    func configureDoubleHeightStatusBar() {
        doubleHeightStatusBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDoubleHeightStatusBar)))
    }
    
    @objc
    private func didTapDoubleHeightStatusBar() {
        showCallView(withCall: currentCall!)
    }
    @objc
    private func timerFunction() {
        
    }
    func setCallBanner(displayText: String) {
        DispatchQueue.main.async {
            self.doubleHeightStatusBarTextLabel.text = displayText
        }
    }
    
    func enableCallBanner(animated: Bool) {
        guard doubleHeightStatusBarHeightConstraint != nil else {
            fatalError()
        }
        let height = UIApplication.shared.statusBarHeight * 2
        doubleHeightStatusBarHeightConstraint.constant = height
        view.frame = CGRect(x: 0, y: height, width: view.bounds.width, height: view.bounds.height - height)
//        view.frame = CGRect(x: 0, y: height, width: view.bounds.width, height: view.bounds.height - height)
        if animated {
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseIn], animations: { [self] in
                view.superview?.layoutIfNeeded()
                view.layoutIfNeeded()
            }, completion: nil)
        } else {
            view.superview?.layoutIfNeeded()
            view.layoutIfNeeded()
        }
        doubleHeightStatusBarTextLabel.startFlashing()
    }
    func disableCallBanner(animated: Bool) {
        guard doubleHeightStatusBarHeightConstraint != nil else {
            fatalError()
        }
        doubleHeightStatusBarHeightConstraint.constant = 0
        let bounds = UIScreen.main.bounds
        view.frame = bounds
        if animated {
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseOut], animations: { [self] in
    //            view.frame = bounds
                view.superview?.layoutIfNeeded()
                view.layoutIfNeeded()
            }, completion: nil)
        } else {
            view.superview?.layoutIfNeeded()
            view.layoutIfNeeded()
        }
        doubleHeightStatusBarTextLabel.stopFlashing()
    }
    
    
 
    
    fileprivate func authenticate(animated:Bool = false) {
        guard !AppData.isLoggedIn else { configureTabBarController(); return }
        viewControllers = [.init()]
        guard !(presentedViewController is LoginViewController) else { return }
        let vc = LoginViewController()
        vc.delegate = self
        vc.isModalInPresentation = true
        AppData.clearData()
        AppData.isLoggedIn = false
        DispatchQueue.main.async {
            self.present(vc, animated: animated, completion: nil)
        }
    }
    
    private func configureTabBarController() {
        var controllers = [UINavigationController]()
        
        // MARK: - Tab 1
        let agentsNavController = UINavigationController(rootViewController: AgentsViewController())
        agentsNavController.tabBarItem = Tabs.tab1.tabBarItem
        controllers.append(agentsNavController)
        
        // MARK: - Tab 2
        let callsNavController = UINavigationController(rootViewController: CallsTabAgentsViewController())
        callsNavController.tabBarItem = Tabs.tab2.tabBarItem
        controllers.append(callsNavController)
        
        // MARK: - Tab 3
        let moreViewController = MoreViewController()
        moreViewController.delegate = self
        let moreNavController = UINavigationController(rootViewController: moreViewController)
        moreNavController.tabBarItem = Tabs.tab3.tabBarItem
        controllers.append(moreNavController)
        
        configureTabBarUI()
        viewControllers = controllers
        selectedIndex = AppData.selectedTab.rawValue
    }
    
    private func configureTabBarUI() {
//        tabBar.barTintColor = UIColor.telaGray4
        tabBar.tintColor = UIColor.telaBlue
        let normalAttributes:[NSAttributedString.Key: Any] = [
            .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)!,
            .foregroundColor: UIColor.telaGray7
        ]
        let selectedAttributes:[NSAttributedString.Key: Any] = [
            .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)!,
            .foregroundColor: UIColor.telaBlue
        ]
        UITabBarItem.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
        UITabBarItem.appearance().titlePositionAdjustment.vertical = -5
    }
    
    fileprivate func configureNotifications() {
        if AppData.isLoggedIn && AppData.workerId != 0 {
            requestNotifications {
                DispatchQueue.main.async {
                  if !UIApplication.shared.isRegisteredForRemoteNotifications {
                     UIApplication.shared.registerForRemoteNotifications()
                  }
                    let topic = "operator_ios_\(AppData.workerId)"
                    Messaging.messaging().subscribe(toTopic: topic) { error in
                        if let error = error {
                            printAndLog(message: "### \(#function) Error subscribing to topic: \(topic) | Error: \n\(error)", log: .notifications, logType: .error)
                        } else {
                            printAndLog(message: "Successfully subscribed to topic: \(topic)", log: .notifications, logType: .info)
                        }
                    }
                }
            }
        }
    }
    fileprivate func registerNotifications() {
        if AppData.isLoggedIn && AppData.workerId != 0 {
            requestNotifications {
                DispatchQueue.main.async {
                  if !UIApplication.shared.isRegisteredForRemoteNotifications {
                     UIApplication.shared.registerForRemoteNotifications()
                  }
                    Messaging.messaging().token { (token, error) in
                        if let error = error {
                            printAndLog(message: "### \(#function) Error retrieving fcmToken from Firebase sdk | Error: \n\(error)", log: .notifications, logType: .error)
                        } else if let token = token {
                            AppDelegate.shared.registerFcmTokenOnServer(token: token)
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    func displayIncomingCall(call: Call) {
        guard let callLog = call.callLog else {
            fatalError()
        }
        let callId = callLog.callId
        
        if UIApplication.shared.applicationState == .active {
            let linphoneManager = LinphoneManager.instance()
            let callIDFromPush = linphoneManager.popPushCallID(callId: callId)
            let autoAnswer = ConfigManager.instance().lpConfigBoolForKey(key: "autoanswer_notif_preference")

            if (callIDFromPush && autoAnswer) {
                // accept call automatically
                CallManager.instance().acceptCall(call: call, hasVideo: true)
            } else {
                print("***\(self)*** >>> ### \(#function) ||| About to present CallViewController()")
                AudioServicesPlaySystemSound(linphoneManager.sounds.vibrate)
                showCallView(withCall: call)
            }
        }
    }
    
    
    func showCallView(withCall call: Call) {
        let vc = CallViewController(call: call)
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        DispatchQueue.main.async { [self] in
            present(vc, animated: false)
        }
    }
    
    
}
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        AppData.selectedTab = Tabs(rawValue: selectedIndex)!
    }
}


extension TabBarController: LoginDelegate {
    func didLoginIWithSuccess() {
        configureTabBarController()
//        configureNotifications()
        registerNotifications()
        if AppDelegate.shared.isVOIPEnabled {
            AppDelegate.shared.setupVoipAccount()
        }
    }
}
extension TabBarController: LogoutDelegate {
    func presentLogin() {
        linphoneCore.clearProxyConfig()
        linphoneCore.clearAllAuthInfo()
        AppData.isLoggedIn = false
        authenticate(animated: true)
    }
}
protocol LogoutDelegate: AnyObject {
    func presentLogin()
}
extension TabBarController: CallViewDelegate {
    func didDeclineIncomingCall(call: Call) {
        fatalError()
    }
    
    func callAborted(call: Call) {
        currentCall = nil
    }
    
    
}
