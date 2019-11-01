//
//  SIMDExtension.swift
//
//
//  Created by Stefan Reinhold on 31.10.19.
//

import Foundation

/// Extend floating point SIMD3 types to have a squared length and legth property
extension SIMD3 where Scalar: FloatingPoint {
  /// The squared length of the vector, i.e. the squared 2-norm
  var squaredLength: Scalar { (self * self).sum() }

  /// The eucliedean length of the vector, i.e. the 2-norm
  var length: Scalar { sqrt(squaredLength) }
}

/// Extend fixed width integer SIMD3 types to have a squared length property
extension SIMD3 where Scalar: FixedWidthInteger {
  /// The squared length, i.e. the squared 2-norm.
  /// Uses overflow addition and multiplication
  var squaredLength: Scalar {
    (self &* self).wrappedSum()
  }
}
