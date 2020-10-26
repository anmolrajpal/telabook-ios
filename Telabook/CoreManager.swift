//
//  CoreManager.swift
//  Telabook
//
//  Created by Anmol Rajpal on 22/10/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import linphonesw

@objc class CoreManager: NSObject {
    static var theCoreManager: CoreManager?
    var lc: Core?
    private var mIterateTimer: Timer?

    @objc static func instance() -> CoreManager {
        if (theCoreManager == nil) {
            theCoreManager = CoreManager()
        }
        return theCoreManager!
    }

    @objc func setCore(core: OpaquePointer) {
        lc = Core.getSwiftObject(cObject: core)
    }

    @objc private func iterate() {
        lc?.iterate()
    }

    @objc func startIterateTimer() {
        if (mIterateTimer?.isValid ?? false) {
            print("Iterate timer is already started, skipping ...")
            return
        }
        mIterateTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.iterate), userInfo: nil, repeats: true)
        print("start iterate timer")

    }

    @objc func stopIterateTimer() {
        if let timer = mIterateTimer {
            print("stop iterate timer")
            timer.invalidate()
        }
    }
    
    @objc func stopLinphoneCore() {
        if (lc?.callsNb == 0) {
            //stop iterate when core is off
            lc?.stopAsync()
        }
    }
}
