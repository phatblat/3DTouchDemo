/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Contains the `Line` and `LinePoint` types used to represent and draw lines derived from touches.
*/

import UIKit

class Line: NSObject {
    // MARK: Properties
    
    var points = [LinePoint]()
    
    var isComplete: Bool {
        for point in points where point.type.contains(.NeedsUpdate) {
            return false
        }
        
        return true
    }
    
    // MARK: Interface
    
    func addPointAtLocation(location: CGPoint, preciseLocation: CGPoint, force: CGFloat, timestamp: NSTimeInterval, type: LinePoint.PointType) -> CGRect {
        let point = LinePoint(timestamp: timestamp, force: force, location: location, preciseLocation: preciseLocation, type: type)
        
        var updateRect = updateRectForLinePoint(point)
        
        if let last = points.last {
            let lastRect = updateRectForLinePoint(last)
            updateRect.unionInPlace(lastRect)
        }
        
        points.append(point)
        
        return updateRect
    }
    
    func updatePointLocation(location: CGPoint, preciseLocation: CGPoint, force: CGFloat, forTimestamp timestamp: NSTimeInterval) -> CGRect {
        var updateRect = CGRect.null
        
        for point in points {
            // Ensure the 'next' point after the matching one is added to the `updateRect`.
            if updateRect != CGRect.null {
                updateRect.unionInPlace(updateRectForLinePoint(point))
                break
            }
            
            if point.timestamp == timestamp {
                let oldRect = updateRectForLinePoint(point)
                
                point.location = location
                point.preciseLocation = preciseLocation
                point.force = force
                point.type.insert(.Updated)
                point.type.subtractInPlace(.NeedsUpdate)
                
                let newRect = updateRectForLinePoint(point)
                updateRect = oldRect.union(newRect)
            }
        }
        
        return updateRect
    }
    
    func removePointsWithType(type: LinePoint.PointType) -> CGRect {
        var updateRect = CGRect.null
        var priorPoint: LinePoint?
        
        points = points.filter { point in
            let keepPoint = !point.type.contains(type)
            
            if !keepPoint {
                var rect = self.updateRectForLinePoint(point)
                
                if let priorPoint = priorPoint {
                    rect.unionInPlace(updateRectForLinePoint(priorPoint))
                }
                
                updateRect.unionInPlace(rect)
            }
            
            priorPoint = point
            
            return keepPoint
        }
        
        return updateRect
    }
    
    func cancel() -> CGRect {
        // Process each point in the line and accumulate the `CGRect` containing all the points.
        let updateRect = points.reduce(CGRect.null) { accumulated, point in
            // Update the type set to include `.Cancelled`.
            point.type.unionInPlace(.Cancelled)
            
            /*
                Union the `CGRect` for this point with accumulated `CGRect` and return it. The result is
                supplied to the next invocation of the closure.
            */
            return accumulated.union(updateRectForLinePoint(point))
        }
        
        return updateRect
    }
    
    // MARK: Drawing
    
    func drawInContext(context: CGContext, isDebuggingEnabled: Bool, usePreciseLocation: Bool) {
        var maybePriorPoint: LinePoint?
        
        for point in points {
            guard let priorPoint = maybePriorPoint else {
                maybePriorPoint = point
                continue
            }
            
            // This color will used by default for `.Standard` touches.
            var color = UIColor.blackColor()
            
            if isDebuggingEnabled {
                if point.type.contains(.Cancelled) {
                    color = UIColor.redColor()
                }
                else if point.type.contains(.NeedsUpdate) {
                    color = UIColor.orangeColor()
                }
                else if point.type.contains(.Finger) {
                    color = UIColor.purpleColor()
                }
                else if point.type.contains(.Coalesced) {
                    color = UIColor.greenColor()
                }
                else if point.type.contains(.Predicted) {
                    color = UIColor.blueColor()
                }
            } else {
                if point.type.contains(.Cancelled) {
                    color = UIColor.clearColor()
                }
                else if point.type.contains(.Finger) {
                    color = UIColor.purpleColor()
                }
                if point.type.contains(.Predicted) && !point.type.contains(.Cancelled) {
                    color = color.colorWithAlphaComponent(0.5)
                }
            }
            
            let location = usePreciseLocation ? point.preciseLocation : point.location
            let priorLocation = usePreciseLocation ? priorPoint.preciseLocation : priorPoint.location
            
            CGContextSetStrokeColorWithColor(context, color.CGColor)
            
            CGContextBeginPath(context)
            
            CGContextMoveToPoint(context, priorLocation.x, priorLocation.y)
            CGContextAddLineToPoint(context, location.x, location.y)
            
            CGContextSetLineWidth(context, point.magnitude)
            CGContextStrokePath(context)
            
            maybePriorPoint = point
        }
    }
    
    func drawFixedPointsInContext(context: CGContext, isDebuggingEnabled: Bool, usePreciseLocation: Bool) {
        let allPoints = points
        var committed = [LinePoint]()
        
        for (index, point) in allPoints.enumerate() {
            // Only points whose type does not include `.NeedsUpdate` or `.Predicted` and is not the last point can be committed.
            guard point.type.intersect([.NeedsUpdate, .Predicted]).isEmpty && index < allPoints.count - 1 else {
                committed.append(points.first!)
                break
            }
            
            guard index > 0 else { continue }
            
            // First time to this point should be index 1 if there is a line segment that can be committed.
            let removed = points.removeFirst()
            committed.append(removed)
        }
        
        // If only one point could be committed, no further action is required. Otherwise, draw the `committedLine`.
        guard committed.count > 1 else { return }
        
        let committedLine = Line()
        committedLine.points = committed
        
        committedLine.drawInContext(context, isDebuggingEnabled: isDebuggingEnabled, usePreciseLocation: usePreciseLocation)
    }
    
    // MARK: Convenience
    
    func updateRectForLinePoint(point: LinePoint) -> CGRect {
        var rect = CGRect(origin: point.location, size: CGSize.zero)
        
        // The negative magnitude ensures an outset rectangle.
        let magnitude = -3 * point.magnitude - 2
        rect.insetInPlace(dx: magnitude, dy: magnitude)
        
        return rect
    }
}

class LinePoint: NSObject {
    // MARK: Types
    
    struct PointType: OptionSetType {
        // MARK: Properties
        
        let rawValue: Int
        
        // MARK: Options
        
        static var Standard: PointType    { return self.init(rawValue: 0) }
        static var Coalesced: PointType   { return self.init(rawValue: 1 << 0) }
        static var Predicted: PointType   { return self.init(rawValue: 1 << 1) }
        static var NeedsUpdate: PointType { return self.init(rawValue: 1 << 2) }
        static var Updated: PointType     { return self.init(rawValue: 1 << 3) }
        static var Cancelled: PointType   { return self.init(rawValue: 1 << 4) }
        static var Finger: PointType      { return self.init(rawValue: 1 << 5) }
    }
    
    // MARK: Properties
    
    let timestamp: NSTimeInterval
    var force: CGFloat
    var location: CGPoint
    var preciseLocation: CGPoint
    var type: PointType
    
    var magnitude: CGFloat {
        return max(force, 0.025)
    }
    
    // MARK: Initialization
    
    init(timestamp: NSTimeInterval, force: CGFloat, location: CGPoint, preciseLocation: CGPoint, type: PointType) {
        self.timestamp = timestamp
        self.force = force
        self.location = location
        self.preciseLocation = preciseLocation
        self.type = type
    }
}
