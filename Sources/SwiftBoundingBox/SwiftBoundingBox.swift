//
//  SwiftBoundingBox.swift
//
// Copyright (c) 2019, Stefan Reinhold
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import Foundation

/// A type representing an axis aligned 3D bounding box
///
/// This type represents an axis aligned 3D box. It is uniquely defined by its minmum and its maximum point.
/// The available operations than can be performed on a bounding box depend on its scalar type.
/// Since the imlementation uses `SIMD3<>` types, the scalar must conform to `SIMDScalar`. It also msut
/// to conform to `Numeric` and to `Comparable`.
///
/// ## Types
/// - `Scalar` scalar type of the underlying vector space
/// - `Point` point type with `x`, `y` and `z` components of type `Scalar`
///  - `Size` size type with `width`, `height` and `depth` components of type `Scalar`
///
/// ## Initialization
/// - `init(minPoint:, maxPoint:)` given the minimum and maximum points
/// - `init(minPoint:, size:)` given the minium point and the size
/// - `init(center:, size:)` given center point and size, available iff `Scalar` conforms to `FloatingPoint`
///
/// ## Properties
///  - `minPoint`: minimum point
///  - `maxPoint`: maximum point
///  - `size`: the size of the bounding box
///  - `center`: bounding box center, available iff `Scalar` conforms to `FloatingPoint`
///
/// ## Operations
/// - test if a point in contained in the bounding box: `contains(point:)`
/// - squared distance computation: `squaredDistance(toPoint:)`
/// - distance computation: `distance(toPoint:)`, available iff `Scalar` conforms to `FloatingPoint`
/// - signed squared distance computation: `signedSquaredDistance(toPoint:)`, available iff `Scalar` is not unsigned
/// - distance computation: `distance(toPoint:)`, avilable iff `Scalar : FloatingPoint`
/// - signed distance computation: `signedDistance(toPoint:)`, avilable iff `Scalar` conforms to `FloatingPoint`
public struct BoundingBox<T: SIMDScalar & Numeric & Comparable> {
  /// The underlying scalar type
  public typealias Scalar = T
  /// The 3D point type used to represent the bounding box
  public typealias Point = SIMD3<T>
  
  /// Bounding Box size type
  /// ## Initializatoin
  /// - `init(widht:, height:, depth:)` given width, height and depth, all non-negative
  /// - `init(fromPoint:)` conversion initalization from `Point` type
  /// ## Properties
  /// - `width`: the width, i.e. length along the x-axis
  /// - `height`: the height, i.e. length along the y-axis
  /// - `depth`: the depth, i.e. length along the z-axis
  public struct Size : Equatable {
    /// The width of the box, i.e. length alogn the x-axis
    public let width: Scalar
    /// The height of the box, i.e. length alogn the y-axis
    public let height: Scalar
    /// The depth of the box, i.e. length alogn the z-axis
    public let depth: Scalar
    
    /// Initializes a new size
    /// - Precondition: `width >= 0 && height >= 0 && depth >= 0`
    /// - Parameter width: the length along the x-axis
    /// - Parameter height: the length along the y-axis
    /// - Parameter depth: the length along the z-axis
    public init(width: Scalar, height: Scalar, depth: Scalar) {
      precondition(width >= Scalar.zero && height >= Scalar.zero && depth >= Scalar.zero,
                   "width, height and depth must be non-negative")
      self.width = width
      self.height = height
      self.depth = depth
    }
    
    /// Initializes a size from a point
    ///
    /// `x` maps to `width`, `y` maps to `height` and `z` maps to `depth`
    /// - Precondition: all components must be non-negative
    public init(fromPoint point: Point) {
      self.init(width: point.x, height: point.y, depth: point.z)
    }
  }
  
  /// The minimum point
  public let minPoint: Point
  /// The maximum point
  public let maxPoint: Point
  
  /// Initializes a bounding box given its minimum and maximum points
  ///
  /// - Parameter minPoint: minimum point
  /// - Parameter maxPoint: maximum point
  /// - Precondition: minPoint.{x,y,z}  <= maxPoint.{x,y,z}
  public init(minPoint: Point, maxPoint: Point) {
    precondition(minPoint.x <= maxPoint.x && minPoint.y <= maxPoint.y && minPoint.z <= maxPoint.z,
                 "min point must be less or equal than max point in all coordinates")
    self.minPoint = minPoint
    self.maxPoint = maxPoint
  }
  
  /// Tests if the given point lies inside the bounding box
  ///
  /// For this test, the bounding box surface is defined to lie inside the box.
  /// That is all point that lie beteen each coordinate pair of minPoint and maxPoint are included in the
  /// box, including minPoint and maxPoint. I.e. the bounding box defines a closed range.
  ///
  /// - Parameter point: point to check
  /// - Returns: True if point lies inside the bounding box, false otherwise
  public func contains(point: Point) -> Bool {
    return
      (minPoint.x ... maxPoint.x).contains(point.x) &&
      (minPoint.y ... maxPoint.y).contains(point.y) &&
      (minPoint.z ... maxPoint.z).contains(point.z)
  }
}

// MARK: - Operations where Scalar : FloatingPoint

/// Extensions to bounding boxes where the `Scalar` type conform to `FloatingPoint`
public extension BoundingBox where T: FloatingPoint {
  /// The size of the bounding box
  var size: Size {
    Size(fromPoint: maxPoint - minPoint)
  }
  
  /// The center point of the bounding box
  ///
  /// Only available if `Scalar` conforms to `FloatingPoint`
  var center: Point { (minPoint + maxPoint) / Scalar(2) }
  
  /// Initializes a bounding box by supplying the minPoint and the size
  ///
  /// Only available when `Scalar` conforms to FloatingPoint
  ///
  /// - Parameter minPoint: minimum point
  /// - Parameter size: bounding box size
  init(minPoint: Point, size: Size) {
    self.init(minPoint: minPoint,
              maxPoint: minPoint + Point(size.width, size.height, size.depth))
  }
  
  /// Initializes a bounding box by supplying its center point and its size
  ///
  /// The bounding box extends `size / 2` along each dimension from the center
  /// Only available if `Scalar` conforms to `FloatingPoint`
  ///
  /// - Parameter center: the center point of the bounding box
  /// - Parameter size: the size of the bounding box
  init(center: Point, size: Size) {
    let halfSize = Point(size.width, size.height, size.depth) / T(2)
    self.init(minPoint: center - halfSize, maxPoint: center + halfSize)
  }
  
  /// Computes the squared euclidean distance of a point to the surface of the bounding box
  ///
  /// The distance is defined to be zero iff `point` lies inside the bounding box.
  /// If `point` lies outside the boundng box the squared eucliedean distance between the point
  /// and the closest point on the surface of the bounding box is returned.
  ///
  /// Only available if `Scalar` conforms to `FloatingPoint`
  ///
  /// - Parameter point: point to compute the squared distance for
  /// - Returns: the squared euclidean distance between `point` and the closest surface point, or
  ///    0 if `point` lies inside the bounding box.
  func squaredDistance(toPoint point: Point) -> Scalar {
    let pointOnSurface = point.clamped(lowerBound: minPoint,
                                       upperBound: maxPoint)
    
    let dist = point - pointOnSurface
    return dist.squaredLength
  }
  
  /// Computes the euclidean distance of a ponit to the surface of the bounding box
  ///
  /// The distance is defined to be zero iff `point` lies inside the bounding box.
  /// If `point` lies outside the boundng box the eucliedean distance between the point
  /// and the closest point on the surface of the bounding box is returned.
  ///
  /// Only available if `Scalar` conforms to `FloatingPoint`
  ///
  /// - Parameter point: point to compute the distance for
  /// - Returns: the euclidean distance between `point` and the closest surface point, or
  ///    0 if `point` lies inside the bounding box.
  func distance(toPoint point: Point) -> Scalar {
    return squaredDistance(toPoint: point).squareRoot()
  }
  
  /// Computes the signed squared euclidean distance of a point to the surface of the bounding box
  ///
  /// The squared distance is zero iff `point` lies excaptly on the surface of the bounding box.
  /// If `point` lies inside the bounding box the distance is negative, if it lies outside the distance is positive.
  /// The squared distance is defined as the squared euclidean distance between `point` and the
  /// closest point on the surface of the bounding box.
  ///
  /// Only available if `Scalar` conforms to `FloatingPoint`
  ///
  /// - Parameter point: point to compute the distance for
  /// - Returns: signed squared euclidean distance between `point` and the surface of the bounding box
  func signedSquaredDistance(toPoint point: Point) -> Scalar {
    if contains(point: point) {
      let dMin = point - minPoint
      let dMax = maxPoint - point
      
      let dist = min(dMin.min(), dMax.min())
      
      return dist * dist
    } else {
      return squaredDistance(toPoint: point)
    }
  }
  
  /// Computes the signed euclidean distance of a point to the surface of the bounding box
  ///
  /// The distance is zero iff `point` lies excaptly on the surface of the bounding box.
  /// If `point` lies inside the bounding box the distance is negative, if it lies outside the distance is positive.
  /// The absolute value of the distance is defined as the euclidean distance between `point` and the
  /// closest point on the surface of the bounding box.
  ///
  /// Only available if `Scalar` conforms to `FloatingPoint`
  ///
  /// - Parameter point: point to compute the distance for
  /// - Returns: signed euclidean distance between `point` and the surface of the bounding box
  func signedDistance(toPoint point: Point) -> Scalar {
    if contains(point: point) {
      let dMin = point - minPoint
      let dMax = maxPoint - point
      
      return min(dMin.min(), dMax.min())
      
    } else {
      return distance(toPoint: point)
    }
  }
}

// MARK: - Operations where Scalar : FixedWidthInteger

/// Extention adds implementatiions of common operations if `Scalar` conforms to `FixedWidthInteger`
public extension BoundingBox where T: FixedWidthInteger {
  /// The size of the bounding box
  ///
  /// Only available if `Scalar`conforms to `FixedWithInteger`
  /// - Remark: size will overflow is the box is greater that `Scalar.max` on any dimension
  var size: Size {
    Size(fromPoint: maxPoint &- minPoint)
  }
  
  /// Initializes a bounding box by supplying the minPoint and the size
  ///
  /// Only available when `Scalar` conforms to `FixedWidthInteger`
  ///
  /// - Parameter minPoint: minimum point
  /// - Parameter size: bounding box size
  /// - Remark: If `maxPoint` overflows, the preconditin of `init(minPoint:, maxPoint:)`
  ///     is violated resulting in an fatal error.
  init(minPoint: Point, size: Size) {
    self.init(minPoint: minPoint,
              maxPoint: minPoint &+ Point(size.width, size.height, size.depth))
  }
  
  /// Computes the squared euclidean distance of a point to the surface of the bounding box
  ///
  /// The distance is defined to be zero iff `point` lies inside the bounding box.
  /// If `point` lies outside the boundng box the squared eucliedean distance between the point
  /// and the closest point on the surface of the bounding box is returned.
  ///
  /// Only available if `Scalar` conforms to `FixedWidthInteger`
  ///
  /// - Parameter point: point to compute the squared distance for
  /// - Returns: the squared euclidean distance between `point` and the closest surface point, or
  ///    0 if `point` lies inside the bounding box.
  /// - Remark: Uses overflow arithmetic, so might produce negative values on overflow.
  func squaredDistance(toPoint point: Point) -> Scalar {
    let pointOnSurface = point.clamped(lowerBound: minPoint,
                                       upperBound: maxPoint)
    
    let dist = point &- pointOnSurface
    return dist.squaredLength
  }
}

// MARK: - Operations where Scalar : FixedWidthInteger & SignedNumeric

/// Extention adds implementatiions of common operations if `Scalar` conforms to `FixedWidthInteger`
/// and `SignedNumeric`
public extension BoundingBox where T: FixedWidthInteger & SignedNumeric {
  /// Computes the signed squared euclidean distance of a point to the surface of the bounding box
  ///
  /// The squared distance is zero iff `point` lies excaptly on the surface of the bounding box.
  /// If `point` lies inside the bounding box the distance is negative, if it lies outside the distance is positive.
  /// The squared distance is defined as the squared euclidean distance between `point` and the
  /// closest point on the surface of the bounding box.
  ///
  /// Only available if `Scalar` conforms to `FixedWidthInteger` and `SignedNumeric`
  ///
  /// - Parameter point: point to compute the distance for
  /// - Returns: signed squared euclidean distance between `point` and the surface of the bounding box
  /// - Remark: Uses overflow arithmetic. Neither magnitude nor sign of result is trustworthy on overflow
  func signedSquaredDistance(toPoint point: Point) -> Scalar {
    if contains(point: point) {
      let dMin = point &- minPoint
      let dMax = maxPoint &- point
      
      let dist = min(dMin.min(), dMax.min())
      
      return dist &* dist
    } else {
      return squaredDistance(toPoint: point)
    }
  }
}
