//
//  TopLevelMethods.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
func mapToInteger(value:AnyObject?) -> Int {
   switch value {
   case let value as Int: return value
   case let value as NSNumber: return value.intValue
   case let value as String: return Int(value) ?? 0
   default: return 0
   }
}
let defaultDecoder = JSONDecoder()

extension JSONDecoder {
   static let apiServiceDecoder:JSONDecoder = {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      decoder.dateDecodingStrategy = .multiple
      return decoder
   }()
}
extension JSONEncoder {
   static let apiServiceEncoder:JSONEncoder = {
      let encoder = JSONEncoder()
      encoder.keyEncodingStrategy = .convertToSnakeCase
      return encoder
   }()
}
