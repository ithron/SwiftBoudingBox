# SwiftBoundingBox

A generic 3D axis aligned bounding box implementation in Swift.
The `BoundingBox` can be used with many scalar types. The minimum requirement is that the
scalar type conforms to `Numeric` and `Comparable`. Since `SIMD3<>` types are used for improved
performance, the scalar type must also conform to `SIMDScalar`.

## Usage
Not all initializers, properties and operations are avaiable for all scalar types. For example the 
`center` property is only available if `Scalar` conforms to `FloatingPoint` because there cannot
be an exacpt center for odd sizes, if `Scalar` is an integer type. When `Scalar` conforms to `FixedWidthInteger`
primitive all operations like addition, subtraction and multiplication are performed using overflow
arithmetic, i.e. without any overflow or underflow detection.

### Declaration
`public struct BoundingBox<T> where T : Comparable, T : Numeric, T : SIMDScalar`

### Types
the following three types are defined:
- `Scalar` alias for `T`
- `Point` the type used to represent points in 3D euclidean type. Alias for `SIMD3<Scalar>`.
- `Size` the type used to represent the size of the bounding box. `Size` has three properties:
  + `width: Scalar` length along the x-axis
  + `height: Scalar` length along the y-axis
  + `depth: Scalar` length along the z-axis

### Initialization
- `init(minPoint:, maxPoint:)` creates a bounding box from its minimum and maximum points
- `init(minPoint:, size:)` creates a bounding box from its minimum point and its size
- `init(center: size:)` creates a bouding box from its center point and its size, only avaiable if `Scalar` conforms to `FloatingPoint`

### Properties
- `minPoint: Point` minimum point of the bounding box, i.e. the point with minimal coordinates in all dimensions
- `maxPoint: Point` maximum point of the bounding box, i.e. the point with maximal coordinates in all dimensions
- `size: Size`: the size of the bounding box
- `center: Point` the center of the bounding box, only available if `Scalar` conforms to `FloatingPoint`

### Queries
- `contains(point:)` checks if a point is contained in the bounding box
- `suqaredDistance(toPoint:)` computes the squared euclidean distance from the surface
  of the bounding box to the given point. If the point lies inside the bounding box, the distance is defined
  to be zero.
- `distance(toPoint:)` square root of `squaredDistance(toPoint:)`. Only available if
  `Scalar` conforms to `FloatingPoint`   
- `signedSquaredDistance(toPoint:)` computes the signed squared distance from the bounding box
  to the given point. This squared distance is negative if and only if the point lies inside the bounding box.
  Only available if `Scalar` conforms to `SignedNumeric`
- `signedDistance(toPoint:)` square root of `signedSquaredDistance(toPoint:)`. Only
  availabe if `Scalar` conforms to `FloatingPoint`


## License
This package is licensed under BSD 2-Clause License.
