@testable import SwiftBoundingBox
import XCTest

// MARK: - Common Tests
final class SwiftBoundingBoxTestImpl<Scalar: Comparable & Numeric & SIMDScalar> {
  typealias BBox = BoundingBox<Scalar>
  typealias Point = BBox.Point
  typealias Size = BBox.Size
  
  func testCorrectInitializationOfMinPoint() {
    let minPoint = Point(0, 1, 2)
    let bbox = BBox(minPoint: minPoint,
                    maxPoint: Point(3, 4, 5))
    
    XCTAssertEqual(bbox.minPoint, minPoint)
  }
  
  func testCorrectInitializationOfMaxPoint() {
    let maxPoint = Point(3, 4, 5)
    let bbox = BBox(minPoint: Point(0, 1, 2),
                    maxPoint: Point(3, 4, 5))
    
    XCTAssertEqual(bbox.maxPoint, maxPoint)
  }
  
  func testIfBBContainsCorners() {
    let bbox = BBox(minPoint: Point(repeating: 0),
                    maxPoint: Point(repeating: 1))
    
    let corners = [
      Point(bbox.minPoint.x, bbox.minPoint.y, bbox.minPoint.z),
      Point(bbox.minPoint.x, bbox.minPoint.y, bbox.maxPoint.z),
      Point(bbox.minPoint.x, bbox.maxPoint.y, bbox.minPoint.z),
      Point(bbox.minPoint.x, bbox.maxPoint.y, bbox.maxPoint.z),
      Point(bbox.maxPoint.x, bbox.minPoint.y, bbox.minPoint.z),
      Point(bbox.maxPoint.x, bbox.minPoint.y, bbox.maxPoint.z),
      Point(bbox.maxPoint.x, bbox.maxPoint.y, bbox.minPoint.z),
      Point(bbox.maxPoint.x, bbox.maxPoint.y, bbox.maxPoint.z)
    ]
    
    for corner in corners {
      XCTAssertTrue(bbox.contains(point: corner))
    }
  }
  
  func testIfBBDoesNotContainPointOutsideBB() {
    let bbox = BBox(minPoint: Point(repeating: 0),
                    maxPoint: Point(repeating: 1))
    
    XCTAssertFalse(bbox.contains(point: Point(2, 2, 2)))
  }
  
}

// MARK: - FloatingPoint Tests
extension SwiftBoundingBoxTestImpl where Scalar: FloatingPoint {
  
  func testIfBBSizeIsCorrect() {
    let bbox = BBox(minPoint: Point(-1, 2, -3),
                    maxPoint: Point(5, 3, -3))
    
    let size = bbox.size
    let refSize = Size(width: 6, height: 1, depth: 0)
    
    XCTAssertEqual(size, refSize)
  }
  
  func testIfSizeInitializationIsCorrect() {
    let size = Size(width: 10, height: 20, depth: 5)
    let minPoint = Point(-1, 3, -7)
    let maxPoint = Point(9, 23, -2)
    let bbox = BBox(minPoint: minPoint, size: size)
    
    XCTAssertEqual(bbox.minPoint, minPoint)
    XCTAssertEqual(bbox.maxPoint, maxPoint)
    XCTAssertEqual(bbox.size, size)
  }
  
  func testIfCenterIsCorrect() {
    let bbox = BBox(minPoint: Point(-5, 0, 1),
                    maxPoint: Point(1, 2, 3))
    let center = Point(-2, 1, 2)
    
    XCTAssertEqual(bbox.center, center)
  }
  
  func testIfCenterInitializationIsCorrect() {
    let minPoint = Point(-5, 0, 1)
    let maxPoint = Point(1, 2, 3)
    let size = Size(width: 6, height: 2, depth: 2)
    let center = Point(-2, 1, 2)
    
    let bbox = BBox(center: center, size: size)
    
    XCTAssertEqual(bbox.minPoint, minPoint)
    XCTAssertEqual(bbox.maxPoint, maxPoint)
  }
  
  func testIfPointInsideBBHasDistanceZero() {
    let bbox = BBox(minPoint: Point(repeating: 0),
                    maxPoint: Point(repeating: 2))
    
    let point = Point(repeating: 1)
    
    XCTAssertEqual(bbox.squaredDistance(toPoint: point), 0)
    XCTAssertEqual(bbox.distance(toPoint: point), 0)
  }
  
  func testIfPointOnSurfaceHasDistanceZero() {
    let bbox = BBox(minPoint: Point(repeating: 0),
                    maxPoint: Point(repeating: 2))
    
    let point = Point(2, 1, 0)
    
    XCTAssertEqual(bbox.squaredDistance(toPoint: point), Scalar.zero, accuracy: Scalar.zero.ulp)
    XCTAssertEqual(bbox.distance(toPoint: point), Scalar.zero, accuracy: Scalar.zero.ulp)
  }
  
  func testIfPointsOutsideHaveCorrectDistances() {
    
    let minPoint = Point.zero
    let maxPoint = Point(repeating: 1)
    
    let pointsAndDistances : [(Point, Scalar)] = [
      (Point(minPoint.x - 3, minPoint.y    , minPoint.z    ), 3),
      (Point(maxPoint.x + 3, minPoint.y    , minPoint.z    ), 3),
      (Point(minPoint.x    , minPoint.y - 1, minPoint.z    ), 1),
      (Point(minPoint.x    , maxPoint.y + 1, minPoint.z    ), 1),
      (Point(minPoint.x    , minPoint.y    , minPoint.z - 2), 2),
      (Point(minPoint.x    , minPoint.y    , maxPoint.z + 2), 2),
      (Point(minPoint.x - 2, minPoint.y - 2, minPoint.z - 2), Scalar(12).squareRoot()),
      (Point(maxPoint.x + 2, maxPoint.y + 2, maxPoint.z + 2), Scalar(12).squareRoot()),
    ]
    
    let bbox = BBox(minPoint: minPoint, maxPoint: maxPoint)
    
    for (point, distance) in pointsAndDistances {
      let distSq = distance * distance
      XCTAssertEqual(bbox.squaredDistance(toPoint: point), distSq, accuracy: Scalar.zero.ulp)
      XCTAssertEqual(bbox.distance(toPoint: point), distance, accuracy: Scalar.zero.ulp)
    }
  }
  
  func testIfPointsInsideHaveNegativeSignedDistance() {
    let bbox = BBox(minPoint: Point.zero, maxPoint: Point(repeating: 1))
    
    let point = Point(repeating: Scalar(1)/Scalar(2))
    
    XCTAssertLessThan(bbox.signedSquaredDistance(toPoint: point), Scalar.zero)
    XCTAssertLessThan(bbox.signedDistance(toPoint: point), Scalar.zero)
  }
  
  func testIfPointsOutsideHavePositiveSignedDistance() {
    let bbox = BBox(minPoint: Point.zero, maxPoint: Point(repeating: 1))
    
    let point = Point(repeating: 2)
    
    XCTAssertGreaterThan(bbox.signedSquaredDistance(toPoint: point), Scalar.zero)
    XCTAssertGreaterThan(bbox.signedDistance(toPoint: point), Scalar.zero)
  }
  
  func testIfPointInsideHasCorrectSignedDistance() {
    let bbox = BBox(minPoint: Point.zero, maxPoint: Point(repeating: 1))
    
    let point = Point(repeating: Scalar(1)/Scalar(2))
    let distanceSq = -Scalar(1)/Scalar(4)
    let distance = -Scalar(1)/Scalar(2)
    
    XCTAssertEqual(bbox.signedSquaredDistance(toPoint: point), distanceSq, accuracy: Scalar.zero.ulp)
    XCTAssertEqual(bbox.signedDistance(toPoint: point), distance, accuracy: Scalar.zero.ulp)
  }
}

// MARK: - FixedWidthInteger Tests
extension SwiftBoundingBoxTestImpl where Scalar: FixedWidthInteger {
  func testIfBBSizeIsCorrect() {
    let bbox = BBox(minPoint: Point(-1, 2, -3),
                    maxPoint: Point(5, 3, -3))
    
    let size = bbox.size
    let refSize = Size(width: 6, height: 1, depth: 0)
    
    XCTAssertEqual(size, refSize)
  }
  
  func testIfSizeInitializationIsCorrect() {
    let size = Size(width: 10, height: 20, depth: 5)
    let minPoint = Point(-1, 3, -7)
    let maxPoint = Point(9, 23, -2)
    let bbox = BBox(minPoint: minPoint, size: size)
    
    XCTAssertEqual(bbox.minPoint, minPoint)
    XCTAssertEqual(bbox.maxPoint, maxPoint)
    XCTAssertEqual(bbox.size, size)
  }
  
  func testIfPointInsideBBHasDistanceZero() {
    let bbox = BBox(minPoint: Point(repeating: 0),
                    maxPoint: Point(repeating: 2))
    
    let point = Point(repeating: 1)
    
    XCTAssertEqual(bbox.squaredDistance(toPoint: point), 0)
  }
  
  func testIfPointOnSurfaceHasDistanceZero() {
    let bbox = BBox(minPoint: Point(repeating: 0),
                    maxPoint: Point(repeating: 2))
    
    let point = Point(2, 1, 0)
    
    XCTAssertEqual(bbox.squaredDistance(toPoint: point), Scalar.zero)
  }
  
  func testIfPointsOutsideHaveCorrectDistances() {
     
     let minPoint = Point.zero
     let maxPoint = Point(repeating: 1)
     
     let pointsAndDistances : [(Point, Scalar)] = [
       (Point(minPoint.x - 3, minPoint.y    , minPoint.z    ), 9),
       (Point(maxPoint.x + 3, minPoint.y    , minPoint.z    ), 9),
       (Point(minPoint.x    , minPoint.y - 1, minPoint.z    ), 1),
       (Point(minPoint.x    , maxPoint.y + 1, minPoint.z    ), 1),
       (Point(minPoint.x    , minPoint.y    , minPoint.z - 2), 4),
       (Point(minPoint.x    , minPoint.y    , maxPoint.z + 2), 4),
       (Point(minPoint.x - 2, minPoint.y - 2, minPoint.z - 2), 12),
       (Point(maxPoint.x + 2, maxPoint.y + 2, maxPoint.z + 2), 12),
     ]
     
     let bbox = BBox(minPoint: minPoint, maxPoint: maxPoint)
     
     for (point, distSq) in pointsAndDistances {
       XCTAssertEqual(bbox.squaredDistance(toPoint: point), distSq)
     }
   }
}

// MARK: - Signed FixedWidthInteger Tests
extension SwiftBoundingBoxTestImpl where Scalar: FixedWidthInteger & SignedInteger {
  
  func testIfPointsInsideHaveNegativeSignedDistance() {
    let bbox = BBox(minPoint: Point.zero, maxPoint: Point(repeating: 2))
    
    let point = Point(repeating: Scalar(1))
    
    XCTAssertLessThan(bbox.signedSquaredDistance(toPoint: point), Scalar.zero)
  }
  
  func testIfPointsOutsideHavePositiveSignedDistance() {
    let bbox = BBox(minPoint: Point.zero, maxPoint: Point(repeating: 1))
    
    let point = Point(repeating: 2)
    
    XCTAssertGreaterThan(bbox.signedSquaredDistance(toPoint: point), Scalar.zero)
  }
  
  func testIfPointInsideHasCorrectSignedDistance() {
    let bbox = BBox(minPoint: Point.zero, maxPoint: Point(repeating: 3))
    
    let point = Point(repeating: 2)
    let distanceSq = Scalar(-1)
    
    XCTAssertEqual(bbox.signedSquaredDistance(toPoint: point), distanceSq)
  }
}

// MARK: - Test Calls
final class SwiftBoundingBoxTests: XCTestCase {
  let testImplFloat = SwiftBoundingBoxTestImpl<Float>()
  let testImplInt64 = SwiftBoundingBoxTestImpl<Int64>()
  
  func testCorrectInitializationOfMinPoint() {
    testImplFloat.testCorrectInitializationOfMinPoint()
    testImplInt64.testCorrectInitializationOfMinPoint()
  }
  
  func testCorrectInitializationOfMaxPoint() {
    testImplFloat.testCorrectInitializationOfMaxPoint()
    testImplInt64.testCorrectInitializationOfMaxPoint()
  }
  
  func testIfBBContainsCorners() {
    testImplFloat.testIfBBContainsCorners()
    testImplInt64.testIfBBContainsCorners()
  }
  
  func testIfBBDoesNotContainsPointOutsideBB() {
    testImplFloat.testIfBBDoesNotContainPointOutsideBB()
    testImplInt64.testIfBBDoesNotContainPointOutsideBB()
  }
  
  func testIfBBSizeIsCorrect() {
    testImplFloat.testIfBBSizeIsCorrect()
    testImplInt64.testIfBBSizeIsCorrect()
  }
  
  func testIfSizeInitializationIsCorrect() {
    testImplFloat.testIfSizeInitializationIsCorrect()
    testImplInt64.testIfSizeInitializationIsCorrect()
  }
  
  func testIfCenterIsCorrect() {
    testImplFloat.testIfCenterIsCorrect()
  }
  
  func testIfCenterInitializationIsCorrect() {
    testImplFloat.testIfCenterInitializationIsCorrect()
  }
  
  func testIfPointInsideBBHasDistanceZero() {
    testImplFloat.testIfPointInsideBBHasDistanceZero()
    testImplInt64.testIfPointInsideBBHasDistanceZero()
  }
  
  func testIfPointOnSurfaceHasDistanceZero() {
    testImplFloat.testIfPointOnSurfaceHasDistanceZero()
    testImplInt64.testIfPointOnSurfaceHasDistanceZero()
  }
  
  func testIfPointsOutsideHaveCorrectDistances() {
    testImplFloat.testIfPointsOutsideHaveCorrectDistances()
    testImplInt64.testIfPointsOutsideHaveCorrectDistances()
  }
  
  func testIfPointsInsideHaveNegativeSignedDistance() {
    testImplFloat.testIfPointsInsideHaveNegativeSignedDistance()
    testImplInt64.testIfPointsInsideHaveNegativeSignedDistance()
  }
  
  func testIfPointsOutsideHavePositiveSignedDistance() {
    testImplFloat.testIfPointsOutsideHavePositiveSignedDistance()
    testImplInt64.testIfPointsOutsideHavePositiveSignedDistance()
  }
  
  func testIfPointInsideHasCorrectSignedDistance() {
    testImplFloat.testIfPointInsideHasCorrectSignedDistance()
    testImplInt64.testIfPointInsideHasCorrectSignedDistance()
  }
  
  static var allTests = [
    ("testIfBBContainsCorners", testIfBBContainsCorners),
    ("testIfBBContainsCorners", testIfBBContainsCorners),
    ("testIfBBSizeIsCorrect", testIfBBSizeIsCorrect),
    ("testIfPointInsideBBHasDistanceZero", testIfPointInsideBBHasDistanceZero)
  ]
}
