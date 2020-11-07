//
//  CallManager.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/10/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CallKit
import linphonesw
import AVFoundation

@objc class CallAppData: NSObject {
    @objc var batteryWarningShown = false
    @objc var videoRequested = false /*set when user has requested for video*/
}

/*
* CallManager is a class that manages application calls and supports callkit.
* There is only one CallManager by calling CallManager.instance().
*/
@objc class CallManager: NSObject {
    static var theCallManager: CallManager?
    let providerDelegate: CallProviderDelegate! // to support callkit
    let callController: CXCallController! // to support callkit
    let manager: CoreManagerDelegate! // callbacks of the linphonecore
    var lc: Core?
    @objc var speakerBeforePause : Bool = false
    @objc var speakerEnabled : Bool = false
    @objc var bluetoothEnabled : Bool = false
    @objc var nextCallIsTransfer: Bool = false
    @objc var alreadyRegisteredForNotification: Bool = false
    var referedFromCall: String?
    var referedToCall: String?
    var endCallkit: Bool = false

    fileprivate override init() {
        providerDelegate = CallProviderDelegate()
        callController = CXCallController()
        manager = CoreManagerDelegate()
    }

    @objc static func instance() -> CallManager {
        if (theCallManager == nil) {
            theCallManager = CallManager()
        }
        return theCallManager!
    }

    @objc func setCore(core: OpaquePointer) {
        lc = Core.getSwiftObject(cObject: core)
        lc?.addDelegate(delegate: manager)
    }

    @objc static func getAppData(call: OpaquePointer) -> CallAppData? {
        let sCall = Call.getSwiftObject(cObject: call)
        return getAppData(sCall: sCall)
    }
    
    static func getAppData(sCall:Call) -> CallAppData? {
        if (sCall.userData == nil) {
            return nil
        }
        return Unmanaged<CallAppData>.fromOpaque(sCall.userData!).takeUnretainedValue()
    }

    @objc static func setAppData(call:OpaquePointer, appData: CallAppData) {
        let sCall = Call.getSwiftObject(cObject: call)
        setAppData(sCall: sCall, appData: appData)
    }
    
    static func setAppData(sCall:Call, appData:CallAppData?) {
        if (sCall.userData != nil) {
            Unmanaged<CallAppData>.fromOpaque(sCall.userData!).release()
        }
        if (appData == nil) {
            sCall.userData = nil
        } else {
            sCall.userData = UnsafeMutableRawPointer(Unmanaged.passRetained(appData!).toOpaque())
        }
    }

    @objc func findCall(callId: String?) -> OpaquePointer? {
        let call = callByCallId(callId: callId)
        return call?.getCobject
    }

    func callByCallId(callId: String?) -> Call? {
        if (callId == nil) {
            return nil
        }
        let calls = lc?.calls
        if let callTmp = calls?.first(where: { $0.callLog?.callId == callId }) {
            return callTmp
        }
        return nil
    }

    @objc static func callKitEnabled() -> Bool {
        #if !targetEnvironment(simulator)
        let shouldUseCallKit = ConfigManager.instance().lpConfigBoolForKey(key: "use_callkit", section: "app")
        lpLog.message(msg: "*** \(self) > ### \(#function) => | Should use callKit preference from linphonerc enabled: \(shouldUseCallKit)")
        if shouldUseCallKit {
            return true
        }
        #endif
        return false
    }

    @objc func allowSpeaker() -> Bool {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            // For now, ipad support only speaker.
            return true
        }

        var allow = true
        let newRoute = AVAudioSession.sharedInstance().currentRoute
        if (newRoute.outputs.count > 0) {
            let route = newRoute.outputs[0].portType
            allow = !( route == .lineOut || route == .headphones || (AudioHelper.bluetoothRoutes() as Array).contains(where: {$0 == route}))
        }

        return allow
    }

    @objc func enableSpeaker(enable: Bool) {
        speakerEnabled = enable
        do {
            if (enable && allowSpeaker()) {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                UIDevice.current.isProximityMonitoringEnabled = false
                bluetoothEnabled = false
            } else {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                let buildinPort = AudioHelper.builtInAudioDevice()
                try AVAudioSession.sharedInstance().setPreferredInput(buildinPort)
                UIDevice.current.isProximityMonitoringEnabled = (lc!.callsNb > 0)
            }
        } catch {
            lpLog.error(msg: "*** \(self) > ### \(#function) => Failed to change audio route: err \(error)")
        }
    }

    func requestTransaction(_ transaction: CXTransaction, action: String) {
        callController.request(transaction) { error in
            if let error = error {
                lpLog.error(msg: "*** \(self) > ### \(#function) => CallKit: Requested transaction \(action) failed because: \(error)")
            } else {
                lpLog.message(msg: "*** \(self) > ### \(#function) => CallKit: Requested transaction \(action) successfully")
            }
        }
    }

    // From ios13, display the callkit view when the notification is received.
    @objc func displayIncomingCall(callId: String) {
        if let uuid = CallManager.instance().providerDelegate.uuids["\(callId)"],
           let callInfo = providerDelegate.callInfos[uuid] {
            if callInfo.declined {
                // This call was declined.
                lpLog.message(msg: "*** \(self) > ### \(#function) => This call was declined; Reporting new incoming call and ending it immediately beause from > iOS 13 it's mandatory to report callkit call.")
                providerDelegate.reportIncomingCall(call:nil, uuid: uuid, handle: "Calling", hasVideo: false)
                providerDelegate.endCall(uuid: uuid)
            }
            return
        }
        if let call = CallManager.instance().callByCallId(callId: callId) {
            lpLog.message(msg: "*** \(self) > ### \(#function) => Linphone Call Found for call-id: [\(callId)]. Getting display name and displaying incoming call now.")
//            let addr = FastAddressBook.displayName(for: call?.remoteAddress?.getCobject) ?? "Unknow"
            let addr = call.remoteAddress?.displayName ?? "Unknown"
            let hasVideo = UIApplication.shared.applicationState == .active && (lc!.videoActivationPolicy?.automaticallyAccept ?? false) && (call.remoteParams?.videoEnabled ?? false)
            displayIncomingCall(call: call, handle: addr, hasVideo: hasVideo, callId: callId)
        } else {
            lpLog.message(msg: "*** \(self) > ### \(#function) => Linphone Call not found for call-id: [\(callId)]. Displaying incoming call with handle: Calling")
            displayIncomingCall(call: nil, handle: "Calling", hasVideo: true, callId: callId)
        }
    }

    func displayIncomingCall(call:Call?, handle: String, hasVideo: Bool, callId: String) {
        let uuid = UUID()
        let callInfo = CallInfo.newIncomingCallInfo(callId: callId)

        providerDelegate.callInfos.updateValue(callInfo, forKey: uuid)
        providerDelegate.uuids.updateValue(uuid, forKey: callId)
        providerDelegate.reportIncomingCall(call:call, uuid: uuid, handle: handle, hasVideo: hasVideo)
    }

    @objc func acceptCall(call: OpaquePointer?, hasVideo:Bool) {
        if (call == nil) {
            print("Can not accept null call!")
            return
        }
        let call = Call.getSwiftObject(cObject: call!)
        acceptCall(call: call, hasVideo: hasVideo)
    }

    func acceptCall(call: Call, hasVideo:Bool) {
        do {
            let callParams = try lc!.createCallParams(call: call)
            callParams.videoEnabled = hasVideo
            if (ConfigManager.instance().lpConfigBoolForKey(key: "edge_opt_preference")) {
                let low_bandwidth = (AppManager.network() == .network_2g)
                if (low_bandwidth) {
                    lpLog.message(msg: "*** \(self) > ### \(#function) > Linphone Low bandwidth mode")
                }
                callParams.lowBandwidthEnabled = low_bandwidth
            }

            //We set the record file name here because we can't do it after the call is started.
            let address = call.callLog?.fromAddress
            let writablePath = AppManager.recordingFilePathFromCall(address: address?.username ?? "")
            lpLog.message(msg: "*** \(self) > ### \(#function) > (Recording File) path: \(String(describing: writablePath))")
            callParams.recordFile = writablePath

            try call.acceptWithParams(params: callParams)
            lpLog.message(msg: "*** \(self) > ### \(#function) > Linphone Call accepted successfully!")
        } catch {
            lpLog.error(msg: "*** \(self) > ### \(#function) > Linphone Failed to accept call because error: \(error)")
        }
    }

    // for outgoing call. There is not yet callId
    @objc func startCall(addr: OpaquePointer?, isSas: Bool) {
        if (addr == nil) {
            lpLog.message(msg: "*** \(self) > ### \(#function) > Linphone Can not start a call with null address!")
            return
        }

        let sAddr = Address.getSwiftObject(cObject: addr!)
        if (CallManager.callKitEnabled() && !CallManager.instance().nextCallIsTransfer) {
            let uuid = UUID()
//            let name = FastAddressBook.displayName(for: addr) ?? "unknow"
            let name = "Unknown"
            let handle = CXHandle(type: .generic, value: name)
            let startCallAction = CXStartCallAction(call: uuid, handle: handle)
            let transaction = CXTransaction(action: startCallAction)

            let callInfo = CallInfo.newOutgoingCallInfo(addr: sAddr, isSas: isSas)
            providerDelegate.callInfos.updateValue(callInfo, forKey: uuid)
            providerDelegate.uuids.updateValue(uuid, forKey: "")

            requestTransaction(transaction, action: "startCall")
        }else {
            try? doCall(addr: sAddr, isSas: isSas)
        }
    }

    func doCall(addr: Address, isSas: Bool) throws {
//        let displayName = FastAddressBook.displayName(for: addr.getCobject)
        let displayName:String? = addr.displayName
        let lcallParams = try CallManager.instance().lc!.createCallParams(call: nil)
        if ConfigManager.instance().lpConfigBoolForKey(key: "edge_opt_preference") && AppManager.network() == .network_2g {
            print("Enabling low bandwidth mode")
            lcallParams.lowBandwidthEnabled = true
        }

        if (displayName != nil) {
            try addr.setDisplayname(newValue: displayName!)
        }

        if(ConfigManager.instance().lpConfigBoolForKey(key: "override_domain_with_default_one")) {
            try addr.setDomain(newValue: ConfigManager.instance().lpConfigStringForKey(key: "domain", section: "assistant"))
        }

        if (CallManager.instance().nextCallIsTransfer) {
            let call = CallManager.instance().lc!.currentCall
            try call?.transfer(referTo: addr.asString())
            CallManager.instance().nextCallIsTransfer = false
        } else {
            //We set the record file name here because we can't do it after the call is started.
            let writablePath = AppManager.recordingFilePathFromCall(address: addr.username )
            print("record file path: \(writablePath)")
            lcallParams.recordFile = writablePath
            if (isSas) {
                lcallParams.mediaEncryption = .ZRTP
            }
            let call = CallManager.instance().lc!.inviteAddressWithParams(addr: addr, params: lcallParams)
            if (call != nil) {
                // The LinphoneCallAppData object should be set on call creation with callback
                // - (void)onCall:StateChanged:withMessage:. If not, we are in big trouble and expect it to crash
                // We are NOT responsible for creating the AppData.
                let data = CallManager.getAppData(sCall: call!)
                if (data == nil) {
                    print("New call instanciated but app data was not set. Expect it to crash.")
                    /* will be used later to notify user if video was not activated because of the linphone core*/
                } else {
                    data!.videoRequested = lcallParams.videoEnabled
                    CallManager.setAppData(sCall: call!, appData: data)
                }
            }
        }
    }

    @objc func groupCall() {
        if (CallManager.callKitEnabled()) {
            let calls = lc?.calls
            if (calls == nil || calls!.isEmpty) {
                return
            }
            let firstCall = calls!.first?.callLog?.callId ?? ""
            let lastCall = (calls!.count > 1) ? calls!.last?.callLog?.callId ?? "" : ""

            let currentUuid = CallManager.instance().providerDelegate.uuids["\(firstCall)"]
            if (currentUuid == nil) {
                lpLog.message(msg: "*** \(self) > ### \(#function) > Linphone Can not find correspondant call to group.")
                return
            }

            let newUuid = CallManager.instance().providerDelegate.uuids["\(lastCall)"]
            let groupAction = CXSetGroupCallAction(call: currentUuid!, callUUIDToGroupWith: newUuid)
            let transcation = CXTransaction(action: groupAction)
            requestTransaction(transcation, action: "groupCall")

            // To simulate the real group call action
            let heldAction = CXSetHeldCallAction(call: currentUuid!, onHold: false)
            let otherTransacation = CXTransaction(action: heldAction)
            requestTransaction(otherTransacation, action: "heldCall")
        } else {
            try? lc?.addAllToConference()
        }
    }

    @objc func removeAllCallInfos() {
        providerDelegate.callInfos.removeAll()
        providerDelegate.uuids.removeAll()
    }

    // To be removed.
    static func configAudioSession(audioSession: AVAudioSession) {
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat, options: AVAudioSession.CategoryOptions(rawValue: AVAudioSession.CategoryOptions.allowBluetooth.rawValue | AVAudioSession.CategoryOptions.allowBluetoothA2DP.rawValue))
            try audioSession.setMode(AVAudioSession.Mode.voiceChat)
            try audioSession.setPreferredSampleRate(48000.0)
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            lpLog.error(msg: "*** \(self) > ### \(#function) > CallKit: Unable to config audio session because : \(error)")
        }
    }

    @objc func terminateCall(call: OpaquePointer?) {
        if (call == nil) {
            lpLog.message(msg: "*** \(self) > ### \(#function) > Can not terminate null call!")
            return
        }
        let call = Call.getSwiftObject(cObject: call!)
        do {
            try call.terminate()
            lpLog.message(msg: "*** \(self) > ### \(#function) > Call terminated succesfully!")
        } catch {
            lpLog.message(msg: "*** \(self) > ### \(#function) > Failed to terminate call because \(error)")
        }
        if (UIApplication.shared.applicationState == .background) {
            CoreManager.instance().stopLinphoneCore()
        }
    }

    @objc func markCallAsDeclined(callId: String) {
        if !CallManager.callKitEnabled() {
            return
        }

        let uuid = providerDelegate.uuids["\(callId)"]
        if (uuid == nil) {
            lpLog.message(msg: "*** \(self) > ### \(#function) > Marking call with callID: [\(callId)] as declined.")
            let uuid = UUID()
            providerDelegate.uuids.updateValue(uuid, forKey: callId)
            let callInfo = CallInfo.newIncomingCallInfo(callId: callId)
            callInfo.declined = true
            callInfo.reason = Reason.Busy
            providerDelegate.callInfos.updateValue(callInfo, forKey: uuid)
        } else {
            // end call
            providerDelegate.endCall(uuid: uuid!)
        }
    }

    @objc func setHeld(call: OpaquePointer, hold: Bool) {
        let sCall = Call.getSwiftObject(cObject: call)
        let callid = sCall.callLog?.callId ?? ""
        let uuid = providerDelegate.uuids["\(callid)"]

        if (uuid == nil) {
            lpLog.message(msg: "*** \(self) > ### \(#function) > Can not find correspondant call to group.")
            return
        }
        let setHeldAction = CXSetHeldCallAction(call: uuid!, onHold: hold)
        let transaction = CXTransaction(action: setHeldAction)

        requestTransaction(transaction, action: "setHeld")
    }
}

class CoreManagerDelegate: CoreDelegate {
    static var speaker_already_enabled : Bool = false

    
    override func onRegistrationStateChanged(lc: Core, cfg: ProxyConfig, cstate: RegistrationState, message: String) {
        if lc.proxyConfigList.count == 1 && (cstate == .Failed || cstate == .Cleared){
            // terminate callkit immediately when registration failed or cleared, supporting single proxy configuration
            CallManager.instance().endCallkit = true
            for call in CallManager.instance().providerDelegate.uuids {
                CallManager.instance().providerDelegate.endCall(uuid: call.value)
            }
        } else {
            CallManager.instance().endCallkit = false
        }
    }
    
    override func onCallStateChanged(lc: Core, call: Call, cstate: Call.State, message: String) {
        let addr = call.remoteAddress;
//        let address = FastAddressBook.displayName(for: addr?.getCobject) ?? "Unknow"
        let address = addr?.displayName ?? "Unknown"
        let callLog = call.callLog
        let callId = callLog?.callId
        let video = UIApplication.shared.applicationState == .active && (lc.videoActivationPolicy?.automaticallyAccept ?? false) && (call.remoteParams?.videoEnabled ?? false)
        // we keep the speaker auto-enabled state in this static so that we don't
        // force-enable it on ICE re-invite if the user disabled it.
        CoreManagerDelegate.speaker_already_enabled = false

        if (call.userData == nil) {
            let appData = CallAppData()
            CallManager.setAppData(sCall: call, appData: appData)
        }


        switch cstate {
            case .IncomingReceived:
                if (CallManager.callKitEnabled()) {
                    if let uuid = CallManager.instance().providerDelegate.uuids["\(callId!)"] {
                        // The app is now registered, updated the call already existed.
                        lpLog.message(msg: "*** \(self) > ### \(#function) > [\(cstate)] => UUID not nil: The app is now registered, updated the call already existed.\n Attempting to update callkit call")
                        CallManager.instance().providerDelegate.updateCall(uuid: uuid, handle: address, hasVideo: video)
                        
                        if let callInfo = CallManager.instance().providerDelegate.callInfos[uuid] {
                            if callInfo.declined {
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    do {
                                        try call.decline(reason: callInfo.reason)
                                        lpLog.message(msg: "*** \(self) > ### \(#function) > Call \(call) with uuid: [\(uuid)] declined successfully!")
                                    } catch {
                                        lpLog.error(msg: "*** \(self) > ### \(#function) > Failed to decline call because error: \(error.localizedDescription)")
                                    }
                                }
                            } else if callInfo.accepted {
                                // The call is already answered.
                                lpLog.message(msg: "*** \(self) > ### \(#function) > [\(cstate)] => The call is already answered. About to accept call; Doesn't make sense, right?")
                                CallManager.instance().acceptCall(call: call, hasVideo: video)
                            }
                        }
                    } else {
                        print("### \(#function) - \(cstate) => About to display incoming call because UUID is nil")
                        CallManager.instance().displayIncomingCall(call: call, handle: address, hasVideo: video, callId: callId!)
                    }
                } else if (UIApplication.shared.applicationState != .active) {
                    // not support callkit , use notif
                    let content = UNMutableNotificationContent()
                    content.title = NSLocalizedString("Incoming call", comment: "")
                    content.body = address
                    content.sound = UNNotificationSound.init(named: UNNotificationSoundName.init("notes_of_the_optimistic.caf"))
                    content.categoryIdentifier = "call_cat"
                    content.userInfo = ["CallId" : callId!]
                    let req = UNNotificationRequest.init(identifier: "call_request", content: content, trigger: nil)
                        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
                }
                break
            case .StreamsRunning:
                if (CallManager.callKitEnabled()) {
                    let uuid = CallManager.instance().providerDelegate.uuids["\(callId!)"]
                    if (uuid != nil) {
                        let callInfo = CallManager.instance().providerDelegate.callInfos[uuid!]
                        if (callInfo != nil && callInfo!.isOutgoing && !callInfo!.connected) {
                            lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: outgoing call connected with uuid \(uuid!) and callId \(callId!)")
                            CallManager.instance().providerDelegate.reportOutgoingCallConnected(uuid: uuid!)
                            callInfo!.connected = true
                            CallManager.instance().providerDelegate.callInfos.updateValue(callInfo!, forKey: uuid!)
                        }
                    }
                }

                if (CallManager.instance().speakerBeforePause) {
                    CallManager.instance().speakerBeforePause = false
                    CallManager.instance().enableSpeaker(enable: true)
                    CoreManagerDelegate.speaker_already_enabled = true
                }
                break
            case .OutgoingInit,
                 .OutgoingProgress,
                 .OutgoingRinging,
                 .OutgoingEarlyMedia:
                if (CallManager.callKitEnabled()) {
                    let uuid = CallManager.instance().providerDelegate.uuids[""]
                    if (uuid != nil) {
                        let callInfo = CallManager.instance().providerDelegate.callInfos[uuid!]
                        callInfo!.callId = callId!
                        CallManager.instance().providerDelegate.callInfos.updateValue(callInfo!, forKey: uuid!)
                        CallManager.instance().providerDelegate.uuids.removeValue(forKey: "")
                        CallManager.instance().providerDelegate.uuids.updateValue(uuid!, forKey: callId!)

                        lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: outgoing call started connecting with uuid \(uuid!) and callId \(callId!)")
                        CallManager.instance().providerDelegate.reportOutgoingCallStartedConnecting(uuid: uuid!)
                    } else {
                        CallManager.instance().referedToCall = callId
                    }
                }
                break
            case .End,
                 .Error:
                UIDevice.current.isProximityMonitoringEnabled = false
                CoreManagerDelegate.speaker_already_enabled = false
                if (CallManager.instance().lc!.callsNb == 0) {
                    CallManager.instance().enableSpeaker(enable: false)
                    // disable this because I don't find anygood reason for it: _bluetoothAvailable = FALSE;
                    // furthermore it introduces a bug when calling multiple times since route may not be
                    // reconfigured between cause leading to bluetooth being disabled while it should not
                    CallManager.instance().bluetoothEnabled = false
                }

                if UIApplication.shared.applicationState != .active && (callLog == nil || callLog?.status == .Missed || callLog?.status == .Aborted || callLog?.status == .EarlyAborted)  {
                    // Configure the notification's payload.
                    let content = UNMutableNotificationContent()
                    content.title = NSString.localizedUserNotificationString(forKey: NSLocalizedString("Missed call", comment: ""), arguments: nil)
                    content.body = NSString.localizedUserNotificationString(forKey: address, arguments: nil)

                    // Deliver the notification.
                    let request = UNNotificationRequest(identifier: "call_request", content: content, trigger: nil) // Schedule the notification.
                    let center = UNUserNotificationCenter.current()
                    center.add(request) { (error : Error?) in
                        if let err = error {
                            lpLog.error(msg: "*** \(self) > ### \(#function) > Error while adding notification request : \(err.localizedDescription)")
                        }
                    }
                }

                if (CallManager.callKitEnabled()) {
                    var uuid = CallManager.instance().providerDelegate.uuids["\(callId!)"]
                    if (callId == CallManager.instance().referedToCall) {
                        // refered call ended before connecting
                        lpLog.message(msg: "*** \(self) > ### \(#function) > Callkit: end refered to call :  \(String(describing: CallManager.instance().referedToCall))")
                        CallManager.instance().referedFromCall = nil
                        CallManager.instance().referedToCall = nil
                    }
                    if uuid == nil {
                        // the call not yet connected
                        uuid = CallManager.instance().providerDelegate.uuids[""]
                    }
                    if (uuid != nil) {
                        if (callId == CallManager.instance().referedFromCall) {
                            lpLog.message(msg: "*** \(self) > ### \(#function) > Callkit: end refered from call : \(String(describing: CallManager.instance().referedFromCall))")
                            CallManager.instance().referedFromCall = nil
                            let callInfo = CallManager.instance().providerDelegate.callInfos[uuid!]
                            callInfo!.callId = CallManager.instance().referedToCall ?? ""
                            CallManager.instance().providerDelegate.callInfos.updateValue(callInfo!, forKey: uuid!)
                            CallManager.instance().providerDelegate.uuids.removeValue(forKey: callId!)
                            CallManager.instance().providerDelegate.uuids.updateValue(uuid!, forKey: callInfo!.callId)
                            CallManager.instance().referedToCall = nil
                            break
                        }

                        let transaction = CXTransaction(action:
                        CXEndCallAction(call: uuid!))
                        CallManager.instance().requestTransaction(transaction, action: "endCall")
                    }
                }
                break
            case .Released:
                call.userData = nil
                break
            case .Referred:
                CallManager.instance().referedFromCall = call.callLog?.callId
                break
            default:
                break
        }

        if (cstate == .IncomingReceived || cstate == .OutgoingInit || cstate == .Connected || cstate == .StreamsRunning) {
            if ((call.currentParams?.videoEnabled ?? false) && !CoreManagerDelegate.speaker_already_enabled && !CallManager.instance().bluetoothEnabled) {
                CallManager.instance().enableSpeaker(enable: true)
                CoreManagerDelegate.speaker_already_enabled = true
            }
        }

        // post Notification kLinphoneCallUpdate
        
        NotificationCenter.default.post(name: .linphoneCallUpdate, object: self, userInfo: [
            AnyHashable("call"): call,    // <<<< NSValue.init(pointer:UnsafeRawPointer(call.getCobject)) >>>> <<==== We can also use this. This will convert Opaque Pointer to UnsafeRawPointer and then to NSValue. This is what linphone developers did. But now I'm directly sending OpaquePointer as Value.
            AnyHashable("state"): cstate.rawValue,
            AnyHashable("message"): message
        ])
    }
}




/*
class CallManager {
    var callsChangedHandler: (() -> Void)?
    private let callController = CXCallController()
    
    private(set) var calls: [Call] = []
    
    func callWithUUID(uuid: UUID) -> Call? {
        guard let index = calls.firstIndex(where: { $0.uuid == uuid }) else {
            return nil
        }
        return calls[index]
    }
    
    func add(call: Call) {
        calls.append(call)
        call.stateChanged = { [weak self] in
            guard let self = self else { return }
            self.callsChangedHandler?()
        }
        callsChangedHandler?()
    }
    
    func remove(call: Call) {
        guard let index = calls.firstIndex(where: { $0 === call }) else { return }
        calls.remove(at: index)
        callsChangedHandler?()
    }
    
    func removeAllCalls() {
        calls.removeAll()
        callsChangedHandler?()
    }
    
    func end(call: Call) {
        let endCallAction = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction(action: endCallAction)
        
        requestTransaction(transaction)
    }
    
    private func requestTransaction(_ transaction: CXTransaction) {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction successfully")
            }
        }
    }
    
    func setHeld(call: Call, onHold: Bool) {
        let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        
        let transaction = CXTransaction()
        transaction.addAction(setHeldCallAction)
        
        requestTransaction(transaction)
    }
    
    func startCall(handle: String, videoEnabled: Bool) {
        let handle = CXHandle(type: .phoneNumber, value: handle)
        
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)
        startCallAction.isVideo = videoEnabled
        
        let transaction = CXTransaction(action: startCallAction)
        
        requestTransaction(transaction)
    }
}
*/
