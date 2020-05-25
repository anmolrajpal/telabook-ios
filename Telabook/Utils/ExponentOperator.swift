//
//  ExponentOperator.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation


precedencegroup Exponentiative {
  associativity: left
  higherThan: MultiplicationPrecedence
}

infix operator ~^ : Exponentiative

public func ~^ <N: BinaryInteger>(base: N, power: N) -> N {
    return N.self( pow(Double(base), Double(power)) )
}

public func ~^ <N: BinaryFloatingPoint>(base: N, power: N) -> N {
    return N.self ( pow(Double(base), Double(power)) )
}





// MARK: Assignment Operator
precedencegroup ExponentiativeAssignment {
  associativity: right
  higherThan: MultiplicationPrecedence
}

infix operator ~^= : ExponentiativeAssignment

public func ~^= <N: BinaryInteger>(lhs: inout N, rhs: N) {
    lhs = lhs ~^ rhs
}

public func ~^= <N: BinaryFloatingPoint>(lhs: inout N, rhs: N) {
    lhs = lhs ~^ rhs
}
