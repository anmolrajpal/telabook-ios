//
//  LinphoneManager.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/11/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import linphonesw
import AVFoundation
import CoreTelephony


struct LinphoneManagerSounds {
    let vibrate: SystemSoundID
}
extension LinphoneManager {
    static func bundleFilePath(fileName: String) -> String? {
        return Bundle.main.path(forResource: (fileName as NSString).deletingPathExtension, ofType: (fileName as NSString).pathExtension)
    }
    static func documentFilePath(fileName: String) -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0].absoluteString as NSString
        return documentsDirectory.appendingPathComponent(documentsDirectory as String)
    }

    static func preferenceFilePath(fileName: String) -> String {
        let configPath = Factory.Instance.getConfigDir(context: UnsafeMutablePointer<Int8>(mutating: ("" as NSString).utf8String)) as NSString
        return configPath.appendingPathComponent(fileName)
    }

    static func dataFilePath(fileName: String) -> String {
        let dataDir = Factory.Instance.getDataDir(context: UnsafeMutablePointer<Int8>(mutating: ("" as NSString).utf8String)) as NSString
        return dataDir.appendingPathComponent(fileName)
    }
}

var needToStop: Bool = false
var coreStopped: Bool = false
var lpLog: LoggingService!
@objc
class LinphoneManager: NSObject {
    
    // MARK: - Declarations
    
    static var theLinphoneManager: LinphoneManager?
    var theLinphoneCore: Core!
    var pausedCallBgTask: UIBackgroundTaskIdentifier?
    var incallBgTask: UIBackgroundTaskIdentifier?
    var pushBgTaskRefer: UIBackgroundTaskIdentifier?
    var pushBgTaskCall: UIBackgroundTaskIdentifier?
    var pushBgTaskMsg: UIBackgroundTaskIdentifier?
   
    var libStarted = false
    var wasRemoteProvisioned = false
    var config: linphonesw.Config!
    var logDelegate: LinphoneLoggingServiceManager!
    var coreDelegate: LinphoneCoreManagerDelegate!

    var pushCallIDs = [String]()
    var remoteNotificationToken:Data?
    var pushKitToken:Data?
    
    var callCenter:CTCallCenter?
    var currentCallContextBeforeGoingBackground = CallContext()
    var logManager:LinphoneLoggingServiceManager!
    
    var shouldCheckVersionUpdate = false
    var isBluetoothAvailable = false
    var lastKeepAliveDate:Date?
    
    
    var sounds: LinphoneManagerSounds
    
    struct CallContext {
        var call: Call?
        var isCameraEnabled: Bool = false
    }
    
    
    // MARK: - Init / deinit
    
    fileprivate override init() {
        self.sounds = .init(vibrate: kSystemSoundID_Vibrate)
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChangeListenerCallback(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
        self.overrideDefaultSettings()
        
    }
    deinit {
        print("### \(self) - Deinitialized")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    @objc static func instance() -> LinphoneManager {
        if (theLinphoneManager == nil) {
            theLinphoneManager = LinphoneManager()
        }
        return theLinphoneManager!
    }
    
    
    
    func launchLinphoneCore() {
        
        if (libStarted) {
            lpLog.message(msg: "Liblinphone is already initialized!")
            return
        }
        
        libStarted = true
        
        signal(SIGPIPE, SIG_IGN)
        
        // create linphone core
        createLinphoneCore()
        //            _iapManager = [[InAppProductsManager alloc] init];
        
        // - Security fix - remove multi transport migration, because it enables tcp or udp, if by factoring settings only
        // tls is enabled.     This is a problem for new installations.
        // linphone_core_migrate_to_multi_transport(theLinphoneCore);
        
        // init audio session (just getting the instance will init)
        let audioSession = AVAudioSession.sharedInstance()
        let bAudioInputAvailable = audioSession.isInputAvailable
        
        do {
            try audioSession.setActive(false)
        } catch {
            lpLog.error(msg: "audioSession setActive failed: \(error.localizedDescription)")
        }
        
        if (!bAudioInputAvailable) {
            DispatchQueue.main.async {
                UIAlertController.showTelaAlert(title: "No microphone".localized(), message: "You need to plug a microphone to your device to use the application.".localized())
            }
        }
        
        if UIApplication.shared.applicationState == .background {
            // go directly to bg mode
            _ = enterBackgroundMode()
        }
    }

    static func linphoneOnRegistrationStateChanged(lc: Core, cfg: ProxyConfig, state: RegistrationState, message: String) {
        lpLog.message(msg: "New registration state: \(state) | (message: \(message)")
        
        let error = cfg.error
        var message = String()
        
        switch error {
        case .Forbidden:
            message = "Bad credentials, check your account settings".localized()
        case .NoResponse:
            message = "No response received from remote".localized()
        case .UnsupportedContent:
            message = "Unsupported content".localized()
        case .IOError:
            message = "Cannot reach the server: either it is an invalid address or it may be temporary down.".localized()
        case .Unauthorized:
            message = "Operation is unauthorized because missing credential".localized()
        case .NoMatch:
            message = "Operation could not be executed by server or remote client because it didn't have any context for it".localized()
        case .MovedPermanently:
            message = "Resource moved permanently".localized()
        case .Gone:
            message = "Resource no longer exists".localized()
        case .TemporarilyUnavailable:
            message = "Temporarily unavailable".localized()
        case .AddressIncomplete:
            message = "Address incomplete".localized()
        case .NotImplemented:
            message = "Not implemented".localized()
        case .BadGateway:
            message = "Bad gateway".localized()
        case .ServerTimeout:
            message = "Server timeout".localized()
        case .NotAcceptable,
             .DoNotDisturb,
             .Declined,
             .NotFound,
             .NotAnswered,
             .Busy,
             .None,
             .SessionIntervalTooSmall,
             .Unknown:
            message = "Unknown error".localized()
        }

        // Post event
        let dictionary:[AnyHashable: Any] = [
            "state": state,
            "cfg": cfg,
            "message": message
        ]
        NotificationCenter.default.post(name: .linphoneRegistrationUpdate, object: self, userInfo: dictionary)
    }
    
    
    static func linphoneOnNotifyPresenceReceivedForURIorTelephone(lc: Core, lf: Friend, uriOrTel: String, presenceModel: PresenceModel) {
        // Post event
        let dictionary:[AnyHashable: Any] = [
            "friend": lf,
            "uri": uriOrTel,
            "presence_model": presenceModel
        ]
        NotificationCenter.default.post(name: .linphoneNotifyPresenceReceivedForUriOrTel, object: self, userInfo: dictionary)
    }
    static func linphoneOnAuthenticationRequested(lc: Core, authInfo: AuthInfo, method: AuthMethod) {
        lpLog.message(msg: "### \(#function)")
    }
    static func linphoneOnMessageReceived(lc: Core, room: ChatRoom, message: ChatMessage) {
        lpLog.message(msg: "### \(#function)")
    }
    static func linphoneOnMessageReceivedUnableDecrypt(lc: Core, room: ChatRoom, message: ChatMessage) {
        lpLog.message(msg: "### \(#function)")
    }
    static func linphoneOnTransferStateChanged(lc: Core, transfered: Call, newCallState: Call.State) {
        lpLog.message(msg: "### \(#function)")
    }
    static func linphoneOnIsComposingReceived(lc: Core, room: ChatRoom) {
        lpLog.message(msg: "### \(#function)")
    }
    static func linphoneOnConfiguringStatus(lc: Core, status: ConfiguringState, message: String) {
        lpLog.message(msg: "### \(#function) | Configuring Status: \(status) | message: \(message)")
        // Post event
        let dictionary:[AnyHashable: Any] = [
            "state": status.rawValue,
            "message": message
        ]
        // dispatch the notification asynchronously
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .linphoneConfiguringStateUpdate, object: self, userInfo: dictionary)
        }
    }
    static func linphoneOnGlobalStateChanged(lc: Core, gstate: GlobalState, message: String) {
        // hmmmm Noisy
        LinphoneManager.instance().globalStateDidChange(lc: lc, gstate: gstate, message: message)
    }
    func globalStateDidChange(lc: Core, gstate: GlobalState, message: String) {
        lpLog.message(msg: "### \(#function) | Global State changed to: \(gstate) | message: \(message)")
        // Post event
        let dictionary:[AnyHashable: Any] = [
            "state": gstate.rawValue,
            "message": message
        ]
        
        if let core = theLinphoneCore,
           linphone_core_get_global_state(core.getCobject) == LinphoneGlobalOff {
            CoreManager.instance().stopIterateTimer()
        }
        
        // dispatch the notification asynchronously
        DispatchQueue.main.async {
            if let core = self.theLinphoneCore,
               linphone_core_get_global_state(core.getCobject) == LinphoneGlobalOff {
                NotificationCenter.default.post(name: .linphoneGlobalStateUpdate, object: self, userInfo: dictionary)
            }
        }
    }
    static func linphoneOnNotifyReceived(lc: Core, lev: Event, notifiedEvent: String, body: Content) {
        onNotifyReceived(lc: lc, event: lev, notifyEvent: notifiedEvent, content: body)
    }
    class func onNotifyReceived(lc: Core, event: Event, notifyEvent: String, content: Content) {
        // Post event
        let dictionary:[AnyHashable: Any] = [
            "event": event,
            "notified_event": notifyEvent,
            "content": content
        ]
        NotificationCenter.default.post(name: .linphoneNotifyReceived, object: self, userInfo: dictionary)
    }
    /*
    /// below function is converted from obj-c to swift. However, not using it because it's yucky.
    private func linphone_iphone_notify_received(_ lc: Core, _ lev: Event, _ notified_event: String, _ body: Content) {
        (linphone_core_cbs_get_user_data(linphone_core_get_current_callbacks(lc.getCobject!)) as? LinphoneManager)?
            .onNotifyReceived(lc: lc, event: lev, notifyEvent: notified_event, content: body)
    }
    */
    static func linphoneOnCallEncryptionChanged(lc: Core, call: Call, on: Bool, authenticationToken: String) {
        onCallEncryptionChanged(lc: lc, call: call, on: on, token: authenticationToken)
    }
    class func onCallEncryptionChanged(lc: Core, call: Call, on: Bool, token: String) {
        // Post event
        let dictionary:[AnyHashable: Any] = [
            "call": call,
            "on": on,
            "token": token
        ]
        NotificationCenter.default.post(name: .linphoneCallEncryptionChanged, object: self, userInfo: dictionary)
    }
    static func linphoneOnCallLogUpdated(lc: Core, newcl: CallLog) {
        if newcl.status == .EarlyAborted {
            CallManager.instance().markCallAsDeclined(callId: newcl.callId)
        }
    }
    class LinphoneCoreManagerDelegate: CoreDelegate {
        override func onRegistrationStateChanged(lc: Core, cfg: ProxyConfig, cstate: RegistrationState, message: String) {
            linphoneOnRegistrationStateChanged(lc: lc, cfg: cfg, state: cstate, message: message)
        }
        override func onNotifyPresenceReceivedForUriOrTel(lc: Core, lf: Friend, uriOrTel: String, presenceModel: PresenceModel) {
            linphoneOnNotifyPresenceReceivedForURIorTelephone(lc: lc, lf: lf, uriOrTel: uriOrTel, presenceModel: presenceModel)
        }
        override func onAuthenticationRequested(lc: Core, authInfo: AuthInfo, method: AuthMethod) {
            linphoneOnAuthenticationRequested(lc: lc, authInfo: authInfo, method: method)
        }
        override func onMessageReceived(lc: Core, room: ChatRoom, message: ChatMessage) {
            linphoneOnMessageReceived(lc: lc, room: room, message: message)
        }
        override func onMessageReceivedUnableDecrypt(lc: Core, room: ChatRoom, message: ChatMessage) {
            linphoneOnMessageReceivedUnableDecrypt(lc: lc, room: room, message: message)
        }
        override func onTransferStateChanged(lc: Core, transfered: Call, newCallState: Call.State) {
            linphoneOnTransferStateChanged(lc: lc, transfered: transfered, newCallState: newCallState)
        }
        override func onIsComposingReceived(lc: Core, room: ChatRoom) {
            linphoneOnIsComposingReceived(lc: lc, room: room)
        }
        override func onConfiguringStatus(lc: Core, status: ConfiguringState, message: String) {
            linphoneOnConfiguringStatus(lc: lc, status: status, message: message)
        }
        override func onGlobalStateChanged(lc: Core, gstate: GlobalState, message: String) {
            linphoneOnGlobalStateChanged(lc: lc, gstate: gstate, message: message)
//            lpLog.message(msg: "global state changed: \(gstate) : \(message) \n")
//            if (gstate == .Shutdown) {
//                needToStop = true
//            } else if (gstate == .Off) {
//                coreStopped = true
//            }
        }
        override func onNotifyReceived(lc: Core, lev: Event, notifiedEvent: String, body: Content) {
            linphoneOnNotifyReceived(lc: lc, lev: lev, notifiedEvent: notifiedEvent, body: body)
        }
        override func onCallEncryptionChanged(lc: Core, call: Call, on: Bool, authenticationToken: String) {
            linphoneOnCallEncryptionChanged(lc: lc, call: call, on: on, authenticationToken: authenticationToken)
        }
        override func onCallLogUpdated(lc: Core, newcl: CallLog) {
            linphoneOnCallLogUpdated(lc: lc, newcl: newcl)
        }
    }
    private func createLinphoneCore() {
        guard theLinphoneCore == nil else {
            lpLog.debug(msg: "linphonecore is already created")
            return
        }
        do {
//            config = linphonesw.Config.newForSharedCore(appGroupId: "", configFilename: "linphonerc", factoryPath: "")
            lpLog = LoggingService.Instance
            
            logManager = try LinphoneLoggingServiceManager(config: config, log: lpLog, domain: "Telabook")

            /*
            Instanciate a LinphoneCore object
            */
            theLinphoneCore = try Factory.Instance.createSharedCoreWithConfig(config: config, systemContext: nil, appGroupId: "", mainCore: true)
            theLinphoneCore.callkitEnabled = true
            coreDelegate = LinphoneCoreManagerDelegate()
            theLinphoneCore.addDelegate(delegate: coreDelegate)
            
            CallManager.instance().setCore(core: theLinphoneCore.getCobject!)
            CoreManager.instance().setCore(core: theLinphoneCore.getCobject!)
            ConfigManager.instance().setDb(db: config.getCobject!)
            
            try theLinphoneCore.start()
            lpLog.message(msg: "Linphone core - \(theLinphoneCore!) started succesfully")
            
            // Setting transport to udp since our server only accept that.
            let transports = theLinphoneCore.transports!
            transports.dtlsPort = 0
            transports.tcpPort = 0
            transports.tlsPort = 0
            transports.udpPort = Int(LC_SIP_TRANSPORT_RANDOM)
            
            try theLinphoneCore.setTransports(newValue: transports)
            lpLog.message(msg: "Succesfully set linphoneCore transport to UDP only")
            
            
            theLinphoneCore.reloadMsPlugins(path: "")
            
//            migrationAllPost()

            /* Use the rootca from framework, which is already set*/
            //linphone_core_set_root_ca(theLinphoneCore, [LinphoneManager bundleFile:@"rootca.pem"].UTF8String);
            theLinphoneCore.userCertificatesPath = LinphoneManager.cacheDirectory

            /* The core will call the linphone_iphone_configuring_status_changed callback when the remote provisioning is loaded
               (or skipped).
               Wait for this to finish the code configuration */
            
            NotificationCenter.default.addObserver(self, selector: #selector(globalStateChangedNotificationHandler(_:)), name: .linphoneGlobalStateUpdate, object:nil)
            NotificationCenter.default.addObserver(self, selector: #selector(configuringStateChangedNotificationHandler(_:)), name: .linphoneConfiguringStateUpdate, object:nil)
            

            /*call iterate once immediately in order to initiate background connections with sip server or remote provisioning
             * grab, if any */
            iterate()
            // start scheduler
            CoreManager.instance().startIterateTimer()
            
            
//            scheduler = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
//                /* main loop for receiving notifications and doing background linphonecore work: */
//                linphoneCore.iterate()
//            }
        } catch {
            let errorMessage = "### \(#function) - Error starting core. Error: \(error)"
            lpLog.error(msg: errorMessage)
            print(errorMessage)
        }
    }
    
    @objc
    func globalStateChangedNotificationHandler(_ notification: Notification) {
        guard let dictionary = notification.userInfo,
              let stateValue = dictionary["state"] as? Int,
              let state = GlobalState(rawValue: stateValue) else {
            fatalError()
        }
        if state == .On {
            finishCoreConfiguration()
        }
    }
    @objc
    func configuringStateChangedNotificationHandler(_ notification: Notification) {
        guard let dictionary = notification.userInfo,
              let stateValue = dictionary["state"] as? Int,
              let state = ConfiguringState(rawValue: stateValue)
        else { fatalError() }
        
        wasRemoteProvisioned = state == .Successful
        
        if wasRemoteProvisioned {
            if let proxyConfig = linphoneCore.defaultProxyConfig {
                configurePushToken(forLinphoneProxyConfig: proxyConfig)
            }
        }
    }
    
    
    /** Should be called once per linphone_core_new() */
    func finishCoreConfiguration() {
        //Force keep alive to workaround push notif on chat message
        LinphoneManager.getLc().keepAliveEnabled = true

        
        enableProxyPublish(enabled: UIApplication.shared.applicationState == .active)
        
        lpLog.message(msg: "Linphone core: \(Core.getVersion) started on device: \(UIDevice.current.model)")

        // Post event
        let dictionary:[AnyHashable: Any] = ["core": theLinphoneCore!]
        
        NotificationCenter.default.post(name: .linphoneCoreUpdate, object:LinphoneManager.instance(), userInfo:dictionary)
    }
    
    func setPushTokenToLinphone(remoteNotificationToken token: Data?) {
        if remoteNotificationToken == token {
            return
        }
        remoteNotificationToken = token
        configurePushTokenForLinphoneProxyConfigs()
    }
    func setPushTokenToLinphone(pushKitToken token: Data?) {
        if pushKitToken == token {
            return
        }
        pushKitToken = token
        configurePushTokenForLinphoneProxyConfigs()
    }
    private func configurePushTokenForLinphoneProxyConfigs() {
        let proxies = linphoneCore.proxyConfigList
        proxies.forEach {
            configurePushToken(forLinphoneProxyConfig: $0)
        }
    }
    func configurePushToken(forLinphoneProxyConfig proxyConfig: ProxyConfig) {
        proxyConfig.edit()
        
        let remoteTokenData = remoteNotificationToken
        let pushKitTokenData = pushKitToken
        let isPushNotificationEnabled = proxyConfig.isPushNotificationAllowed
        if (remoteTokenData != nil || pushKitTokenData != nil) && isPushNotificationEnabled {
            var remoteTokenString:String?
            var pushKitTokenString:String?
            if let data = remoteTokenData {
               remoteTokenString = data.map { String(format: "%02x", $0) }.joined()
            }
            if let data = pushKitTokenData {
                pushKitTokenString = data.map { String(format: "%02x", $0) }.joined()
            }
            
            let token:String
            let service:String
            
            
            if let remoteToken = remoteTokenString, let pkToken = pushKitTokenString {
                token = String(format: "%@:voip&%@:remote", pkToken, remoteToken)
                service = "voip&remote"
            } else if let remoteToken = remoteTokenString {
                token = String(format: "%@:remote", remoteToken)
                service = "remote"
            } else {
                token = String(format: "%@:voip", pushKitTokenString!)
                service = "voip"
            }
            
            let bundleId = Bundle.main.bundleIdentifier!
            let teamId = Config.teamID
            
            let params = String(format: "pn-provider=apns.dev;pn-prid=%@;pn-param=%@.%@.%@", token, teamId, bundleId, service)
            
            print("Proxy Config: \(String(describing: proxyConfig.identityAddress)) configured for push notifications with contact params: \(params)")
            
            
            proxyConfig.contactUriParameters = params
            proxyConfig.contactParameters = ""
            // MARK: - TODO
            /// - tag: Maybe we need to comment above line
            
        } else {
            print("Proxy Config: \(String(describing: proxyConfig.identityAddress)) not configured for push notifications because of no token")
            // no token
            proxyConfig.contactUriParameters = ""
            proxyConfig.contactParameters = ""
        }
        do {
            try proxyConfig.done()
        } catch {
            let errorMessage = "### \(#function): Error configuring proxy: \(proxyConfig) \nError=>\(error)"
            lpLog.error(msg: errorMessage)
            print(errorMessage)
        }
    }
    static var cacheDirectory: String {
        let cachePath = Factory.Instance.getDownloadDir(context: UnsafeMutablePointer<Int8>(mutating: ("" as NSString).utf8String))
        
        let cacheFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        
        let url = cacheFolder.appendingPathComponent(cachePath, isDirectory: false)
        
        // Create it if it doesn’t exist.
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
            } catch {
                let errorMessage = "### \(#function) - Error creating file directory at url: \(url) & Error: \(error)"
                printAndLog(message: errorMessage, log: .ui, logType: .error)
            }
        }
        return cachePath
    }
    
    
    @objc
    func audioRouteChangeListenerCallback(_ notification: Notification) {
        // there is at least one bug when you disconnect an audio bluetooth headset
        // since we only get notification of route having changed, we cannot tell if that is due to:
        // -bluetooth headset disconnected or
        // -user wanted to use earpiece
        // the only thing we can assume is that when we lost a device, it must be a bluetooth one (strong hypothesis though)
        guard let dictionary = notification.userInfo else {
            fatalError()
        }
        let reason = dictionary[AVAudioSessionRouteChangeReasonKey] as? Int ?? 0
        if reason == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue {
            isBluetoothAvailable = false
        }
        
        let newRoute = AVAudioSession.sharedInstance().currentRoute
        
        if newRoute.outputs.count > 0 {
            let routePort = newRoute.outputs[0].portType
            print("Current Audio Route is: \(routePort.rawValue)")
            theLinphoneCore.audioRouteChanged()
            
            CallManager.instance().speakerEnabled = routePort == AVAudioSession.Port.builtInSpeaker
            
            if AudioHelper.bluetoothRoutes().contains(routePort) && !CallManager.instance().speakerEnabled {
                isBluetoothAvailable = true
                CallManager.instance().bluetoothEnabled = true
            } else {
                CallManager.instance().bluetoothEnabled = false
            }
            let dictionary:[AnyHashable: Any] = ["available": isBluetoothAvailable]
            NotificationCenter.default.post(name: .linphoneBluetoothAvailabilityUpdate, object: self, userInfo: dictionary)
        }
    }
    
    
    func setBluetoothEnabled(enable: Bool) {
        if isBluetoothAvailable {
            // The change of route will be done in enableSpeaker
            CallManager.instance().bluetoothEnabled = enable
            if CallManager.instance().bluetoothEnabled {
                var err:Error?
                let bluetoothPort = AudioHelper.bluetoothAudioDevice()
                do {
                    try AVAudioSession.sharedInstance().setPreferredInput(bluetoothPort)
                } catch {
                    print("### \(#function) - Failed to set prefferd input; Error: \(error.localizedDescription)")
                    err = error
                }
                if err != nil {
                    // if setting bluetooth failed, it must be because the device is not available
                    // anymore (disconnected), so deactivate bluetooth.
                    CallManager.instance().bluetoothEnabled = false
                } else {
                    CallManager.instance().speakerEnabled = false
                    return
                }
            }
        }
        CallManager.instance().enableSpeaker(enable: CallManager.instance().speakerEnabled)
    }
    static func getLc() -> Core {
        if LinphoneManager.instance().theLinphoneCore == nil {
            fatalError("Linphone core not initialized yet")
        }
        return LinphoneManager.instance().theLinphoneCore!
    }

    func isLcInitialized() -> Bool {
        if theLinphoneCore == nil {
            return false
        }
        return true
    }
    func startLinphoneCore() {
        do {
            try LinphoneManager.getLc().start()
        } catch {
            print("### \(#function) & Class: \(self) | Failed to start Linphone Core. Error: \(error)")
        }
        CoreManager.instance().startIterateTimer()
    }
    func checkNewVersion() {
        if (!shouldCheckVersionUpdate) {
            return
        }
        if (theLinphoneCore == nil) {
            return
        }
        if let currentVersion = Bundle.versionNumber {
            theLinphoneCore.checkForUpdate(currentVersion: currentVersion)
        }
    }
    func becomeActive() {
        linphoneCore.enterForeground()

        checkNewVersion()

        // enable presence
        if (Int32(floor(NSFoundationVersionNumber)) <= NSFoundationVersionNumber_iOS_9_x_Max) {
            refreshRegisters()
        }
        if pausedCallBgTask != nil {
            UIApplication.shared.endBackgroundTask(pausedCallBgTask!)
            pausedCallBgTask = nil
        }
        if incallBgTask != nil {
            UIApplication.shared.endBackgroundTask(incallBgTask!)
            incallBgTask = nil
        }

        /*IOS specific*/
        theLinphoneCore?.startDtmfStream()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            
        }

        /*start the video preview in case we are in the main view*/
        if (theLinphoneCore?.videoDisplayEnabled ?? false) && ConfigManager.instance().lpConfigBoolForKey(key: "preview_preference") {
            theLinphoneCore?.videoPreviewEnabled = true
        }
        /*check last keepalive handler date*/
        if lastKeepAliveDate != nil {
            let now = Date()
            if now.timeIntervalSince(lastKeepAliveDate!) > 700 {
                let str = lastKeepAliveDate!.description
                print("keepalive handler was called for the last time at \(str)")
            }
        }

        enableProxyPublish(enabled: true)
    }
    func enterBackgroundMode() -> Bool {
        linphoneCore.enterBackground()
        
        let defaultProxyConfig = theLinphoneCore?.defaultProxyConfig
        var shouldEnterBackgroundMode = false
        
        // diable presence
        enableProxyPublish(enabled: false)
        
        if let proxyConfig = defaultProxyConfig {
            let isPushNotificationsEnabled = proxyConfig.isPushNotificationAllowed
            if ConfigManager.instance().lpConfigBoolForKey(key: "backgroundmode_preference") || isPushNotificationsEnabled {
                if (Int32(floor(NSFoundationVersionNumber)) <= NSFoundationVersionNumber_iOS_9_x_Max) {
                    // For registration register
                    refreshRegisters()
                }
            }
            if ConfigManager.instance().lpConfigBoolForKey(key: "voip_mode_preference") && ConfigManager.instance().lpConfigBoolForKey(key: "backgroundmode_preference") && !isPushNotificationsEnabled {
                // Keep this!! Socket VoIP is deprecated after 9.0, but sometimes it's the only way to keep the phone background and receive the call. For example, when there is only local area network.
                // register keepalive
                if UIApplication.shared.setKeepAliveTimeout(600 /*(NSTimeInterval)linphone_proxy_config_get_expires(proxyCfg)*/, handler: { [self] in
                    print("KeepAlive Handler")
                    lastKeepAliveDate = Date()
                    if theLinphoneCore == nil {
                        print("It seems that Linphone BG mode was deactivated, just skipping")
                        return
                    }
//                    [_iapManager check];
                    if (Int32(floor(NSFoundationVersionNumber)) <= NSFoundationVersionNumber_iOS_9_x_Max) {
                        // For registration register
                        refreshRegisters()
                    }
                    theLinphoneCore.iterate()
                }) {
                    print("keepalive handler succesfully registered")
                } else {
                    print("keepalive handler cannot be registered")
                }
                shouldEnterBackgroundMode = true
            }
        }
        let currentCall = theLinphoneCore.currentCall
        let calls = theLinphoneCore.calls
        
        if currentCall == nil && !calls.isEmpty && calls.contains(where: { $0.state != .Paused }) {
            startCallPausedLongRunningTask()
        }
        if !calls.isEmpty {
            shouldEnterBackgroundMode = true // If at least one call exist, enter normal bg mode
        }
        
        if theLinphoneCore != nil {
            theLinphoneCore!.videoPreviewEnabled = false
            iterate()
        }
        theLinphoneCore?.stopDtmfStream()
        
        print("Entering \(shouldEnterBackgroundMode ? "Normal" : "lite") background mode")
        
        if !shouldEnterBackgroundMode && Int32(floor(NSFoundationVersionNumber)) <= NSFoundationVersionNumber_iOS_9_x_Max {
            let pushNotifEnabled = defaultProxyConfig?.isPushNotificationAllowed ?? false
            if pushNotifEnabled {
                print("Keeping lc core to handle push")
                return true
            }
            return false
        }
        return true
        
    }
    
    var isCTCallCenterExists: Bool {
        return callCenter != nil
    }
    func removeCTCallCenterCb() {
        if callCenter != nil {
            lpLog.message(msg: "Removing CT call center listener \(String(describing: callCenter))")
            callCenter?.callEventHandler = nil
        }
        callCenter = nil
    }
    func setupGSMInteraction() {
        removeCTCallCenterCb()
        callCenter = CTCallCenter()
        lpLog.message(msg: "Adding CT call center listener \(callCenter!)")
        
        callCenter?.callEventHandler = { [weak self] call in
            DispatchQueue.main.async {
                self?.handleGSMCallInteration(cCenter: self?.callCenter)
            }
        }
    }

    func handleGSMCallInteration(cCenter: CTCallCenter?) {
        if (Int32(floor(NSFoundationVersionNumber)) <= NSFoundationVersionNumber_iOS_9_x_Max),
           let ct = cCenter {
            
            // pause current call, if any
            let call = theLinphoneCore.currentCall
            if ct.currentCalls != nil {
                if call != nil {
                    lpLog.message(msg: "Pausing SIP call because GSM call")
                    CallManager.instance().speakerBeforePause = CallManager.instance().speakerEnabled;
                    do {
                        try call!.pause()
                    } catch {
                        lpLog.error(msg: "Failed to pause call: \(call!) | Error: \(error.localizedDescription)")
                    }
                    startCallPausedLongRunningTask()
                } else if theLinphoneCore.isInConference {
                    lpLog.message(msg: "Leaving conference call because GSM call")
                    do {
                        try theLinphoneCore.leaveConference()
                    } catch {
                        lpLog.error(msg: "Failed to leave conference on core: \(theLinphoneCore!) | Error: \(error.localizedDescription)")
                    }
                    startCallPausedLongRunningTask()
                }
            } // else nop, keep call in paused state
        }
    }
    
    
    

    
    
    func acceptCallForCallId(callid: String) {
        // first, make sure this callid is not already involved in a call
        let calls = theLinphoneCore.calls
        if let call = calls.first(where: { $0.callLog?.callId == callid }) {
            let withVideo = theLinphoneCore.videoActivationPolicy?.automaticallyAccept ?? false
            CallManager.instance().acceptCall(call: call, hasVideo: withVideo)
        } else {
            lpLog.error(msg: "### \(#function) - No call for call id: \(callid)")
        }
    }

    func addPushCallId(callid: String) {
        // first, make sure this callid is not already involved in a call
//        let calls = theLinphoneCore.calls
//        No idea what the fuck is this -
//        if (bctbx_list_find_custom(calls, (bctbx_compare_func)comp_call_id, [callid UTF8String])) {
//            LOGW(@"Call id [%@] already handled", callid);
//            return;
//        };
        if pushCallIDs.count > 10 /*max number of pending notif*/ {
            pushCallIDs.remove(at: 0)
        }
        pushCallIDs.append(callid)
    }

    func popPushCallID(callId: String) -> Bool {
        for pushCallId in pushCallIDs {
            if pushCallId == callId {
                pushCallIDs.remove(at: pushCallIDs.firstIndex(of: pushCallId)!)
                return true
            }
        }
        return false
    }
    
    
    
    
    func copyDefaultSettings() {
        guard let src = LinphoneManager.bundleFilePath(fileName: "linphonerc"),
              let srcIpad = LinphoneManager.bundleFilePath(fileName: "linphonerc~ipad") else {
            lpLog.error(msg: "Config files not found.")
            fatalError()
        }
        let dst = LinphoneManager.preferenceFilePath(fileName: "linphonerc")
        if (UIDevice.current.userInterfaceIdiom == .pad && FileManager.default.fileExists(atPath: srcIpad)) {
            _ = LinphoneManager.copyFile(srcIpad, destination: dst, override: false, ignore: false)
            return
        }
        _ = LinphoneManager.copyFile(src, destination: dst, override: false, ignore: false)
    }

    func overrideDefaultSettings() {
        guard let factoryPath = LinphoneManager.bundleFilePath(fileName: "linphonerc-factory")
               else {
            lpLog.error(msg: "Config files not found.")
            fatalError()
        }
        let factoryIpad = LinphoneManager.bundleFilePath(fileName: "linphonerc-factory~ipad")
        if let path = factoryIpad,
           UIDevice.current.userInterfaceIdiom == .pad,
           FileManager.default.fileExists(atPath: path) {
            self.config = linphonesw.Config.newForSharedCore(appGroupId: "", configFilename: "linphonerc", factoryPath: path)!
            return
        }
        config = linphonesw.Config.newForSharedCore(appGroupId: "", configFilename: "linphonerc", factoryPath: factoryPath)!
        config.cleanEntry(section: "misc", key: "max_calls")
    }
    
    class func copyFile(_ src: String?, destination dst: String?, override: Bool, ignore: Bool) -> Bool {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: src ?? "") == false {
            if !ignore {
                lpLog.error(msg: "Can't find \"\(String(describing: src))\"")
            }
            return false
        }
        if fileManager.fileExists(atPath: dst ?? "") == true {
            if override {
                do {
                    try fileManager.removeItem(atPath: dst ?? "")
                } catch {
                    lpLog.error(msg: "Can't remove \"\(String(describing: dst))\": \(String(describing: error.localizedDescription))")
                    return false
                }
            } else {
                lpLog.warning(msg: "\"\(String(describing: dst))\" already exists")
                return false
            }
        }
        do {
            try fileManager.copyItem(atPath: src ?? "", toPath: dst ?? "")
        } catch {
            lpLog.error(msg: "Can't copy \"\(String(describing: src))\" to \"\(String(describing: dst))\": \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    func startCallPausedLongRunningTask() {
        pausedCallBgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            print("Call cannot be paused any more, too late")
            UIApplication.shared.endBackgroundTask(self.pausedCallBgTask!)
        })
        print("Long running task started, remaining \(Date.intervalToString(interval: UIApplication.shared.backgroundTimeRemaining)) because at least one call is paused")
    }
    func enableProxyPublish(enabled: Bool) {
        if linphone_core_get_global_state(linphoneCore.getCobject) != LinphoneGlobalOn {
            print("### \(#function) -> Not changing presence configuration because linphone core not ready yet")
            return
        }

        if ConfigManager.instance().lpConfigBoolForKey(key: "publish_presence") {
            // set present to "tv", because "available" does not work yet
            if enabled {
                do {
                    let model = try linphoneCore.createPresenceModelWithActivity(acttype: PresenceActivityType.TV, description: "")
                    linphoneCore.presenceModel = model
                } catch {
                    print("### \(#function) = Error createPresenceModelWithActivity: \(error)")
                }
            }
            
            
            let proxies = linphoneCore.proxyConfigList
            do {
                try proxies.forEach({
                    $0.edit()
                    $0.publishEnabled = enabled
                    try $0.done()
                })
            } catch {
                print("Error setting publish enabled = \(error)")
            }
            // force registration update first, then update friend list subscription
            iterate()
        }
    }
    
    
    // scheduling loop
    func iterate() {
        theLinphoneCore?.iterate()
    }
    
    func refreshRegisters() {
        theLinphoneCore?.refreshRegisters() // just to make sure REGISTRATION is up to date
    }
    
    
    
    
    
    
/*
    func migrateFromUserPrefs() {
        let migrateMigration_flag = "userpref_migration_done"
        if config == nil {
            return
        }
        
        if ConfigManager.instance().lpConfigBoolForKey(key: migrateMigration_flag, defaultValue: false) {
            return
        }

        let defaults = UserDefaults.standard.dictionaryRepresentation()
        let defaults_keys = defaults.keys
        let values = [
            "backgroundmode_preference": NSNumber(value: false),
            "debugenable_preference": NSNumber(value: false),
            "start_at_boot_preference": NSNumber(value: true)
        ]
        var shouldSync = false


        for userpref in values {
            
            guard let userpref = userpref as? String else {
                continue
            }
            
            if defaults_keys.contains(userpref) {
                LOGI("Migrating %@ from user preferences: %d", userpref, (defaults[userpref] as? NSNumber)?.boolValue ?? false)
                lpConfigSetBool((defaults[userpref] as? NSNumber)?.boolValue ?? false, forKey: userpref)
                UserDefaults.standard.removeObject(forKey: userpref)
                shouldSync = true
            } else if lpConfigString(forKey: userpref) == nil {
                // no default value found in our linphonerc, we need to add them
                lpConfigSetBool(values[userpref]?.boolValue ?? false, forKey: userpref)
            }
        }

        if shouldSync {
            LOGI("Synchronizing...")
            UserDefaults.standard.synchronize()
        }
        // don't get back here in the future
        lpConfigSetBool(true, forKey: migrateMigration_flag)
    }
    */
    
    
    
    
    
}















fileprivate extension Date {
    static func intervalToString(interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = .second
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        return formatter.string(from: interval)!
    }
}
