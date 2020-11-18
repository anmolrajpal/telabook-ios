//
//  CallProviderDelegate.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/10/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import AVFoundation
import CallKit
import linphonesw



@objc class CallInfo: NSObject {
    var callId: String = ""
    var accepted = false
    var toAddr: Address?
    var isOutgoing = false
    var sasEnabled = false
    var declined = false
    var connected = false
    var reason: Reason = Reason.None

    static func newIncomingCallInfo(callId: String) -> CallInfo {
        let callInfo = CallInfo()
        callInfo.callId = callId
        return callInfo
    }
    
    static func newOutgoingCallInfo(addr: Address, isSas: Bool) -> CallInfo {
        let callInfo = CallInfo()
        callInfo.isOutgoing = true
        callInfo.sasEnabled = isSas
        callInfo.toAddr = addr
        return callInfo
    }
}

/*
* A delegate to support callkit.
*/
class CallProviderDelegate: NSObject {
    private let provider: CXProvider
    var uuids: [String : UUID] = [:]
    var callInfos: [UUID : CallInfo] = [:]

    override init() {
        provider = CXProvider(configuration: CallProviderDelegate.providerConfiguration)
        super.init()
        provider.setDelegate(self, queue: nil)
    }

    static var providerConfiguration: CXProviderConfiguration = {
        let providerConfiguration = CXProviderConfiguration(localizedName: Bundle.main.infoDictionary!["CFBundleName"] as! String)
        providerConfiguration.ringtoneSound = "notes_of_the_optimistic.caf"
        providerConfiguration.supportsVideo = false
        providerConfiguration.iconTemplateImageData = UIImage(named: "callkit_logo")?.pngData()
        providerConfiguration.supportedHandleTypes = [.generic]

        providerConfiguration.maximumCallsPerCallGroup = 5 // default
        providerConfiguration.maximumCallGroups = 2 // default

        //not show app's calls in tel's history
        //providerConfiguration.includesCallsInRecents = YES;
        
        return providerConfiguration
    }()

    func reportIncomingCall(call:Call?, uuid: UUID, handle: String, hasVideo: Bool) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type:.generic, value: handle)
        update.hasVideo = hasVideo

        let callInfo = callInfos[uuid]
        let callId = callInfo?.callId
        lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: attempting to report new incoming call with call-id: [\(String(describing: callId))] and UUID: [\(uuid.description)]")
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if error == nil {
                let timeout: TimeInterval = 30
                
                if CallManager.instance().endCallkit {
                    CallManager.instance().providerDelegate.endCall(uuid: uuid)
                } else {
                    lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: |* Voila! Displaying incoming call with call-id: [\(String(describing: callId))] and UUID: [\(uuid.description)] now. Setting up this call to end after timout: \(timeout) if not picked up. *|")
                    CallManager.instance().providerDelegate.endCallNotExist(uuid: uuid, timeout: .now() + timeout)
                }
            } else {
                lpLog.error(msg: "*** \(self) > ### \(#function) > CallKit: cannot complete incoming call with call-id: [\(String(describing: callId))] and UUID: [\(uuid.description)] from [\(handle)] caused by [\(error!.localizedDescription)]")
                let code = (error as NSError?)?.code
                switch code {
                case CXErrorCodeIncomingCallError.filteredByDoNotDisturb.rawValue:
                    callInfo?.reason = Reason.DoNotDisturb
                case CXErrorCodeIncomingCallError.filteredByBlockList.rawValue:
                    callInfo?.reason = Reason.DoNotDisturb
                default:
                    callInfo?.reason = Reason.Unknown
                }
                callInfo?.declined = true
                self.callInfos.updateValue(callInfo!, forKey: uuid)
                try? call?.decline(reason: callInfo!.reason)
            }
        }
    }

    func updateCall(uuid: UUID, handle: String, hasVideo: Bool = false) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type:.generic, value:handle)
        update.hasVideo = hasVideo
        provider.reportCall(with:uuid, updated:update);
    }

    func reportOutgoingCallStartedConnecting(uuid:UUID) {
        provider.reportOutgoingCall(with: uuid, startedConnectingAt: nil)
    }

    func reportOutgoingCallConnected(uuid:UUID) {
        provider.reportOutgoingCall(with: uuid, connectedAt: nil)
    }
    
    func endCall(uuid: UUID) {
        provider.reportCall(with: uuid, endedAt: .init(), reason: .failed)
    }

    func endCallNotExist(uuid: UUID, timeout: DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: timeout) {
            let callId = CallManager.instance().providerDelegate.callInfos[uuid]?.callId
            let call = CallManager.instance().callByCallId(callId: callId)
            if (call == nil) {
                lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: ending call now with call-id: \(String(describing: callId)) and UUID: \(uuid) where call object does not exists.")
                CallManager.instance().providerDelegate.endCall(uuid: uuid)
            }
        }
    }
}

// MARK: - CXProviderDelegate
extension CallProviderDelegate: CXProviderDelegate {
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
        let uuid = action.callUUID
        let callId = callInfos[uuid]?.callId

        // remove call infos first, otherwise CXEndCallAction will be called more than onece
        if (callId != nil) {
            uuids.removeValue(forKey: callId!)
        }
        callInfos.removeValue(forKey: uuid)

        let call = CallManager.instance().callByCallId(callId: callId)
        if let call = call {
            CallManager.instance().terminateCall(call: call.getCobject);
            lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: Call ended with call-id: \(String(describing: callId)) an UUID: \(uuid.description).")
        }
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        let uuid = action.callUUID
        let callInfo = callInfos[uuid]
        let callId = callInfo?.callId
        print("CallKit: answer call with call-id: \(String(describing: callId)) and UUID: \(uuid.description).")

        let call = CallManager.instance().callByCallId(callId: callId)
        if (call == nil || call?.state != Call.State.IncomingReceived) {
            let timeout: TimeInterval = 10
            // The application is not yet registered or the call is not yet received, mark the call as accepted. The audio session must be configured here.
            lpLog.message(msg: "*** \(self) > ### \(#function) > The application is not yet registered or the call is not yet received, mark the call as accepted. The audio session must be configured here. Ringing callkit call with timout of \(timeout) seconds.")
            CallManager.configAudioSession(audioSession: AVAudioSession.sharedInstance())
            callInfo?.accepted = true
            callInfos.updateValue(callInfo!, forKey: uuid)
            CallManager.instance().providerDelegate.endCallNotExist(uuid: uuid, timeout: .now() + timeout)
        } else {
            lpLog.message(msg: "*** \(self) > ### \(#function) > Accepting found call: \(call!)")
            CallManager.instance().acceptCall(call: call!, hasVideo: call!.params?.videoEnabled ?? false)
            lpLog.message(msg: "*** \(self) > ### \(#function) > Call Accepted")
        }
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        let uuid = action.callUUID
        let callId = callInfos[uuid]?.callId
        let call = CallManager.instance().callByCallId(callId: callId)
        action.fulfill()
        if (call == nil) {
            return
        }

        do {
            if (CallManager.instance().lc?.isInConference ?? false && action.isOnHold) {
                try CallManager.instance().lc?.leaveConference()
                lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: Leaving conference")
                NotificationCenter.default.post(name: .linphoneCallUpdate, object: self) // hmm wierd! Should include userInfo
                return
            }

            let state = action.isOnHold ? "Paused" : "Resumed"
            lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: Call  with call-id: [\(String(describing: callId))] and UUID: [\(uuid)] paused status changed to: [\(state)]")
            if (action.isOnHold) {
                if (call!.params?.localConferenceMode ?? false) {
                    return
                }
                CallManager.instance().speakerBeforePause = CallManager.instance().speakerEnabled
                try call!.pause()
                lpLog.message(msg: "*** \(self) > ### \(#function) > Call paused with call-id: [\(String(describing: callId))] and UUID: [\(uuid)]")
            } else {
                if (CallManager.instance().lc?.conference != nil && CallManager.instance().lc?.callsNb ?? 0 > 1) {
                    try CallManager.instance().lc?.enterConference()
                    lpLog.message(msg: "*** \(self) > ### \(#function) > Call entered in conference with call-id: [\(String(describing: callId))] and UUID: [\(uuid)]")
                    NotificationCenter.default.post(name: .linphoneCallUpdate, object: self)
                } else {
                    try call!.resume()
                    lpLog.message(msg: "*** \(self) > ### \(#function) > Call resumed with call-id: [\(String(describing: callId))] and UUID: [\(uuid)]")
                }
            }
        } catch {
            lpLog.error(msg: "*** \(self) > ### \(#function) > CallKit: Call set held (paused or resumed) with UUID: [\(uuid)] failed because \(error)")
        }
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        do {
            let uuid = action.callUUID
            let callInfo = callInfos[uuid]
            let addr = callInfo?.toAddr
            if (addr == nil) {
                print("CallKit: can not call a null address!")
                action.fail()
            }

            try CallManager.instance().doCall(addr: addr!, isSas: callInfo?.sasEnabled ?? false)
        } catch {
            print("CallKit: Call started failed because \(error)")
            action.fail()
        }
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetGroupCallAction) {
        print("CallKit: Call grouped callUUid : \(action.callUUID) with callUUID: \(String(describing: action.callUUIDToGroupWith)).")
        do {
            try CallManager.instance().lc?.addAllToConference()
        } catch {
            print("CallKit: Call grouped failed because \(error)")
        }
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        let uuid = action.callUUID
        let callId = callInfos[uuid]?.callId
        lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: Call muted with call-id: \(String(describing: callId)) an UUID: \(uuid.description).")
        CallManager.instance().lc!.micEnabled = !CallManager.instance().lc!.micEnabled
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        let uuid = action.callUUID
        let callId = callInfos[uuid]?.callId
        lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: Call sending dtmf with call-id: \(String(describing: callId)) an UUID: \(uuid.description).")
        let call = CallManager.instance().callByCallId(callId: callId)
        if (call != nil) {
            let digit = (action.digits.cString(using: String.Encoding.utf8)?[0])!
            do {
                try call!.sendDtmf(dtmf: digit)
                lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: Call DTMF Sent with call-id: [\(String(describing: callId))] and UUID: [\(uuid)]")
            } catch {
                lpLog.error(msg: "*** \(self) > ### \(#function) > CallKit: Call send dtmf for UUID: [\(uuid)] failed because \(error)")
            }
        }
        action.fulfill()
    }

    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        let uuid = action.uuid
        let callId = callInfos[uuid]?.callId
        lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: Call time out with call-id: \(String(describing: callId)) an UUID: \(uuid.description).")
        action.fulfill()
    }

    func providerDidReset(_ provider: CXProvider) {
        lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: did reset.")
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: audio session activated.")
        CallManager.instance().lc?.activateAudioSession(actived: true)
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        lpLog.message(msg: "*** \(self) > ### \(#function) > CallKit: audio session deactivated.")
        CallManager.instance().lc?.activateAudioSession(actived: false)
    }
}
