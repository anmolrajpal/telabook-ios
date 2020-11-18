//
//  AudioHelper.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/11/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import AVFoundation

class AudioHelper: NSObject {
    
    static func bluetoothRoutes() -> [AVAudioSession.Port] {
        return [.bluetoothHFP, .carAudio, .bluetoothA2DP, .bluetoothLE]
    }
    static func bluetoothAudioDevice() -> AVAudioSessionPortDescription? {
        return audioDeviceFromTypes(types: bluetoothRoutes())
    }
    
    static func builtInAudioDevice() -> AVAudioSessionPortDescription? {
        let builtInRoutes = [AVAudioSession.Port.builtInMic]
        return audioDeviceFromTypes(types: builtInRoutes)
    }
    static func speakerAudioDevice() -> AVAudioSessionPortDescription? {
        let builtInRoutes = [AVAudioSession.Port.builtInSpeaker]
        return audioDeviceFromTypes(types: builtInRoutes)
    }

    static func audioDeviceFromTypes(types: [AVAudioSession.Port]) -> AVAudioSessionPortDescription? {
        let availableInputs = AVAudioSession.sharedInstance().availableInputs ?? []
        for input in availableInputs {
            if types.contains(input.portType) {
                return input
            }
        }
        return nil
    }
}
