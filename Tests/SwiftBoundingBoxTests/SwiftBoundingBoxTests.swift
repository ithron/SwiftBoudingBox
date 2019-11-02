@testable import SwiftBoundingBox
import XCTest

final class SwiftBoundingBoxTestImpl<Scalar: Comparable & Numeric & SIMDScalar> {
  typealias BBox = BoundingBox<Scalar>
  typealias Point = BBox.Point
  typealias Size = BBox.Size
  
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

extension SwiftBoundingBoxTestImpl where Scalar: FloatingPoint {
  func testIfBBSizeIsCorrect() {
    let bbox = BBox(minPoint: Point(-1, 2, -3),
                    maxPoint: Point(5, 3, -3))
    
    let size = bbox.size
    let refSize = Size(width: 6, height: 1, depth: 0)
    
    XCTAssertEqual(size, refSize)
  }
  
  func testIfPointInsideBBHasDistanceZero() {
    let bbox = BBox(minPoint: Point(repeating: 0),
                    maxPoint: Point(repeating: 2))
    
    let point = Point(repeating: 1)
    
    XCTAssertEqual(bbox.squaredDistance(toPoint: point), 0)
    XCTAssertEqual(bbox.distance(toPoint: point), 0)
  }
}

extension SwiftBoundingBoxTestImpl where Scalar: FixedWidthInteger {
  func testIfBBSizeIsCorrect() {
    let bbox = BBox(minPoint: Point(-1, 2, -3),
                    maxPoint: Point(5, 3, -3))
    
    let size = bbox.size
    let refSize = Size(width: 6, height: 1, depth: 0)
    
    XCTAssertEqual(size, refSize)
  }
  
  func testIfPointInsideBBHasDistanceZero() {
    let bbox = BBox(minPoint: Point(repeating: 0),
                    maxPoint: Point(repeating: 2))
    
    let point = Point(repeating: 1)
    
    XCTAssertEqual(bbox.squaredDistance(toPoint: point), 0)
  }
}

final class SwiftBoundingBoxTests: XCTestCase {
  let testImplFloat = SwiftBoundingBoxTestImpl<Float>()
  let testImplInt64 = SwiftBoundingBoxTestImpl<Int64>()
  
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
  
  func testIfPointInsideBBHasDistanceZero() {
    testImplFloat.testIfPointInsideBBHasDistanceZero()
    testImplInt64.testIfPointInsideBBHasDistanceZero()
  }
  
  static var allTests = [
    ("testIfBBContainsCorners", testIfBBContainsCorners),
    ("testIfBBContainsCorners", testIfBBContainsCorners),
    ("testIfBBSizeIsCorrect", testIfBBSizeIsCorrect),
    ("testIfPointInsideBBHasDistanceZero", testIfPointInsideBBHasDistanceZero)
  ]
}
