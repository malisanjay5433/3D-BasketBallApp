//
//  MathUtils.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import Foundation
import SceneKit

enum MathUtils {
    
    /// Calculates a point along a quadratic Bézier curve for realistic basketball shots
    /// - Parameters:
    ///   - t: Interpolation parameter (0.0 to 1.0)
    ///   - start: Starting point of the curve
    ///   - end: Ending point of the curve
    ///   - apexY: Maximum height (apex) of the curve
    /// - Returns: Point along the curve at parameter t
    static func bezierPoint(t: Float, start: SCNVector3, end: SCNVector3, apexY: Float) -> SCNVector3 {
        // Calculate control point for realistic arc
        let midX = (start.x + end.x) * 0.5
        let midZ = (start.z + end.z) * 0.5
        
        // Create a more realistic basketball arc
        // The control point should be above the midpoint and slightly forward
        let distance = sqrt((end.x - start.x) * (end.x - start.x) + (end.z - start.z) * (end.z - start.z))
        let arcHeight = max(apexY, start.y + 4.0)  // Ensure minimum arc height
        
        // Position control point to create a natural basketball arc
        let controlPoint = SCNVector3(midX, arcHeight, midZ + distance * 0.1)
        
        // Quadratic Bézier curve calculation
        let u = 1 - t
        
        let x = u*u*start.x + 2*u*t*controlPoint.x + t*t*end.x
        let y = u*u*start.y + 2*u*t*controlPoint.y + t*t*end.y
        let z = u*u*start.z + 2*u*t*controlPoint.z + t*t*end.z
        
        return SCNVector3(x, y, z)
    }
    
    /// Calculates distance between two 3D points
    /// - Parameters:
    ///   - point1: First 3D point
    ///   - point2: Second 3D point
    /// - Returns: Distance between the points
    static func distance(from point1: SCNVector3, to point2: SCNVector3) -> Float {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        let dz = point2.z - point1.z
        
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
    
    /// Calculates the midpoint between two 3D points
    /// - Parameters:
    ///   - point1: First 3D point
    ///   - point2: Second 3D point
    /// - Returns: Midpoint between the two points
    static func midpoint(between point1: SCNVector3, and point2: SCNVector3) -> SCNVector3 {
        return SCNVector3(
            (point1.x + point2.x) * 0.5,
            (point1.y + point2.y) * 0.5,
            (point1.z + point2.z) * 0.5
        )
    }
}
