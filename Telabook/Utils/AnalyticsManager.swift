//
//  AnalyticsManager.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/02/22.
//  Copyright © 2022 Anmol Rajpal. All rights reserved.
//

import Foundation
import Mixpanel

final class AnalyticsManager {
   static let shared = AnalyticsManager()
   
   typealias MixpanelUserProperties = [UserProfileProperty: MixpanelType]
   
   enum AnalyticsEvent: String {
      case printLog = "Print Log"
   }
   enum UserProfileProperty: String {
      case countryCode = "Country Code"
      case phoneNumber = "Phone Number"
      case name = "$name"
      case email = "$email"
   }
   func trackEvent(_ event: AnalyticsEvent, properties: Properties? = nil) {
      Mixpanel.mainInstance().track(event: event.rawValue, properties: properties)
   }
   func timeEvent(_ event: AnalyticsEvent) {
      Mixpanel.mainInstance().time(event: event.rawValue)
   }
   /*
   func trackScreen(_ screen: ScreenName, properties: Properties? = nil) {
      let text = "User reached \(screen.displayValue()) screen"
      Mixpanel.mainInstance().track(event: text, properties: properties)
   }
   */
   func setUserProperties(properties: MixpanelUserProperties) {
      Mixpanel.mainInstance().people.set(properties: properties)
   }
   func identifyUser(withDistinctID userID: String) {
      Mixpanel.mainInstance().identify(distinctId: userID)
   }
   func resetSession(completion: (() -> Void)? = nil) {
      Mixpanel.mainInstance().reset(completion: completion)
   }
   func initialize() {
      Mixpanel.initialize(token: Config.mixpanelToken)
      Mixpanel.mainInstance().flushInterval = 15
   }
   func flush(completion: (() -> Void)? = nil) {
      Mixpanel.mainInstance().flush(completion: completion)
   }
}
extension People {
   func set(properties: AnalyticsManager.MixpanelUserProperties) {
      var props = Properties()
      _ = properties.map { (key, value) in
         props[key.rawValue] = value
      }
      set(properties: props)
   }
}
