//
//  Audio.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/10/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//


import AVFoundation

func configureAudioSession() {
    print("Configuring audio session")
    let session = AVAudioSession.sharedInstance()
    do {
        try session.setCategory(.playAndRecord, mode: .voiceChat, options: [])
    } catch (let error) {
        print("Error while configuring audio session: \(error)")
    }
}

func startAudio() {
    print("Starting audio")
}

func stopAudio() {
    print("Stopping audio")
}
