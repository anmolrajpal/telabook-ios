//
//  TapticEngine.swift
//  Telabook
//
//  Created by Anmol Rajpal on 02/02/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

final class TapticEngine {
    enum HapticFeedback { case Error, Warning, Success, Light, Medium, Heavy, Rigid, Soft, SelectionChanged }
    static func generateFeedback(ofType feedback: HapticFeedback) {
//        if !AppData().settingsStore.isHapticsEnabled { return }
        switch feedback {
        case .Error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        case .Warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        case .Success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .Light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .Medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .Heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        case .Rigid:
            if #available(iOS 13.0, *) {
                let generator = UIImpactFeedbackGenerator(style: .rigid)
                generator.impactOccurred()
            } else {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            }
        case .Soft:
            if #available(iOS 13.0, *) {
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.impactOccurred()
            } else {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        case .SelectionChanged:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
}
