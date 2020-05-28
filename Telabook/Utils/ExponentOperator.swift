//
//  ExponentOperator.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation


precedencegroup Exponentiative {
  associativity: left
  higherThan: MultiplicationPrecedence
}

infix operator ~^ : Exponentiative

public func ~^ <T: BinaryInteger>(base: T, power: T) -> T {
    return T.self( pow(Double(base), Double(power)) )
}

public func ~^ <T: BinaryFloatingPoint>(base: T, power: T) -> T {
    return T.self ( pow(Double(base), Double(power)) )
}    




// MARK: Assignment Operator
precedencegroup ExponentiativeAssignment {
  associativity: right
  higherThan: MultiplicationPrecedence
}

infix operator ~^= : ExponentiativeAssignment

public func ~^= <T: BinaryInteger>(lhs: inout T, rhs: T) {
    lhs = lhs ~^ rhs
}

public func ~^= <T: BinaryFloatingPoint>(lhs: inout T, rhs: T) {
    lhs = lhs ~^ rhs
}
