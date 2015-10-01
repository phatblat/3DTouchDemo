/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The `CanvasView` tracks `UITouch`es and represents them as a series of `Line`s.
*/

import UIKit

@available(iOS 9.1, *)
class CanvasView: UIView {
    // MARK: Properties
    
    let isPredictionEnabled = UIDevice.currentDevice().userInterfaceIdiom == .Pad
    let isTouchUpdatingEnabled = true
    
    var usePreciseLocations = false
    var isDebuggingEnabled = false
    
    /// Array containing all line objects that need to be drawn in `drawRect(_:)`.
    var lines = [Line]()
    
    /** 
        Holds a map of `UITouch` objects to `Line` objects whose touch has not ended yet.
    
        Use `NSMapTable` to handle association as `UITouch` doesn't conform to `NSCopying`.
    */
    let activeLines = NSMapTable.strongToStrongObjectsMapTable()
    
    /**
        Holds a map of `UITouch` objects to `Line` objects whose touch has ended but still has points awaiting
        updates.
        
        Use `NSMapTable` to handle association as `UITouch` doesn't conform to `NSCopying`.
    */
    let pendingLines = NSMapTable.strongToStrongObjectsMapTable()
    
    /// A `CGContext` for drawing the last representation of lines no longer receiving updates into.
    lazy var frozenContext: CGContext = {
        let scale = self.window!.screen.scale
        var size = self.bounds.size
        
        size.width *= scale
        size.height *= scale
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, colorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue)

        CGContextSetLineCap(context, .Round)
        let transform = CGAffineTransformMakeScale(scale, scale)
        CGContextConcatCTM(context, transform)
        
        return context!
    }()
    
    /// An optional `CGImage` containing the last representation of lines no longer receiving updates.
    var frozenImage: CGImage?
    
    // MARK: Drawing
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        CGContextSetLineCap(context, .Round)

        frozenImage = frozenImage ?? CGBitmapContextCreateImage(frozenContext)
        
        if let frozenImage = frozenImage {
            CGContextDrawImage(context, bounds, frozenImage)
        }
        
        for line in lines {
            line.drawInContext(context, isDebuggingEnabled: isDebuggingEnabled, usePreciseLocation: usePreciseLocations)
        }
    }
    
    // MARK: Actions
    
    func clear() {
        activeLines.removeAllObjects()
        pendingLines.removeAllObjects()
        lines.removeAll()
        frozenImage = nil
        CGContextClearRect(frozenContext, bounds)
        setNeedsDisplay()
    }
    
    // MARK: Convenience
    
    func drawTouches(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var updateRect = CGRect.null
        
        for touch in touches {
            // Retrieve a line from `activeLines`. If no line exists, create one.
            let line = activeLines.objectForKey(touch) as? Line ?? addActiveLineForTouch(touch)
            
            /*
                Remove prior predicted points and update the `updateRect` based on the removals. The touches 
                used to create these points are predictions provided to offer additional data. They are stale 
                by the time of the next event for this touch.
            */
            updateRect.unionInPlace(line.removePointsWithType(.Predicted))
            
            /*
                Incorporate coalesced touch data. The data in the last touch in the returned array will match
                the data of the touch supplied to `coalescedTouchesForTouch(_:)`
            */
            let coalescedTouches = event?.coalescedTouchesForTouch(touch) ?? []
            let coalescedRect = addPointsOfType(.Coalesced, forTouches: coalescedTouches, toLine: line, currentUpdateRect: updateRect)
            updateRect.unionInPlace(coalescedRect)
            
            /*
                Incorporate predicted touch data. This sample draws predicted touches differently; however, 
                you may want to use them as inputs to smoothing algorithms rather than directly drawing them. 
                Points derived from predicted touches should be removed from the line at the next event for 
                this touch.
            */
            if isPredictionEnabled {
                let predictedTouches = event?.predictedTouchesForTouch(touch) ?? []
                let predictedRect = addPointsOfType(.Predicted, forTouches: predictedTouches, toLine: line, currentUpdateRect: updateRect)
                updateRect.unionInPlace(predictedRect)
            }
        }
        
        setNeedsDisplayInRect(updateRect)
    }
    
    func addActiveLineForTouch(touch: UITouch) -> Line {
        let newLine = Line()
        
        activeLines.setObject(newLine, forKey: touch)
        
        lines.append(newLine)
        
        return newLine
    }
    
    func addPointsOfType(var type: LinePoint.PointType, forTouches touches: [UITouch], toLine line: Line, currentUpdateRect updateRect: CGRect) -> CGRect {
        var accumulatedRect = CGRect.null
        
        for (idx, touch) in touches.enumerate() {
            let isStylus = touch.type == .Stylus
            
            // The visualization displays non-`.Stylus` touches differently.
            if !isStylus {
                type.unionInPlace(.Finger)
            }
            
            // Touches with estimated properties require updates; add this information to the `PointType`.
            if isTouchUpdatingEnabled && !touch.estimatedProperties.isEmpty {
                type.unionInPlace(.NeedsUpdate)
            }
            
            // The last touch in a set of `.Coalesced` touches is the originating touch. Track it differently.
            if type.contains(.Coalesced) && idx == touches.count - 1 {
                type.subtractInPlace(.Coalesced)
                type.unionInPlace(.Standard)
            }
            
            let force = isStylus || touch.force > 0 ? touch.force : 1.0
            
            let touchRect = line.addPointAtLocation(touch.locationInView(self), preciseLocation: touch.preciseLocationInView(self), force: force, timestamp: touch.timestamp, type: type)
            accumulatedRect.unionInPlace(touchRect)
            
            commitLine(line)
        }
        
        return updateRect.union(accumulatedRect)
    }
    
    func endTouches(touches: Set<UITouch>, cancel: Bool) {
        var updateRect = CGRect.null
        
        for touch in touches {
            // Skip over touches that do not correspond to an active line.
            guard let line = activeLines.objectForKey(touch) as? Line else { continue }
            
            // If this is a touch cancellation, cancel the associated line.
            if cancel { updateRect.unionInPlace(line.cancel()) }
            
            // If the line is complete (no points needing updates) or updating isn't enabled, move the line to the `frozenImage`.
            if line.isComplete || !isTouchUpdatingEnabled {
                finishLine(line)
            }
            // Otherwise, add the line to our map of touches to lines pending update.
            else {
                pendingLines.setObject(line, forKey: touch)
            }
            
            // This touch is ending, remove the line corresponding to it from `activeLines`.
            activeLines.removeObjectForKey(touch)
        }
        
        setNeedsDisplayInRect(updateRect)
    }
    
    func updateEstimatedPropertiesForTouches(touches: Set<NSObject>) {
        guard isTouchUpdatingEnabled, let touches = touches as? Set<UITouch> else { return }
        
        var updateRect = CGRect.null
        
        for touch in touches {
            var isPending = false
            
            // Look to retrieve a line from `activeLines`. If no line exists, look it up in `pendingLines`.
            let possibleLine: Line? = activeLines.objectForKey(touch) as? Line ?? {
                let pendingLine = pendingLines.objectForKey(touch) as? Line
                isPending = pendingLine != nil
                return pendingLine
            }()
            
            // If no line is related to the touch, return as there is no additional work to do.
            guard let line = possibleLine else { return }
            
            let updateEstimatedRect = line.updatePointLocation(touch.locationInView(self), preciseLocation: touch.preciseLocationInView(self), force: touch.force, forTimestamp: touch.timestamp)
            updateRect.unionInPlace(updateEstimatedRect)
            
            // If this update updated the last point requiring an update, move the line to the `frozenImage`.
            if isPending && line.isComplete {
                finishLine(line)
                pendingLines.removeObjectForKey(touch)
            }
            // Otherwise, have the line add any points no longer requiring updates to the `frozenImage`.
            else {
                commitLine(line)
            }
            
            setNeedsDisplayInRect(updateRect)
        }
    }
    
    func commitLine(line: Line) {
        // Have the line draw any segments between points no longer being updated into the `frozenContext` and remove them from the line.
        line.drawFixedPointsInContext(frozenContext, isDebuggingEnabled: isDebuggingEnabled, usePreciseLocation: usePreciseLocations)
        
        // Force the `frozenImage` to be regenerated from the `frozenContext` during the next `drawRect(_:)` call.
        frozenImage = nil
    }
    
    func finishLine(line: Line) {
        // Have the line draw any remaining segments into the `frozenContext`.
        line.drawInContext(frozenContext, isDebuggingEnabled: isDebuggingEnabled, usePreciseLocation: usePreciseLocations)
        
        // Force the `frozenImage` to be regenerated from the `frozenContext` during the next `drawRect(_:)` call.
        frozenImage = nil
        
        // Cease tracking this line now that it is finished.
        lines.removeAtIndex(lines.indexOf(line)!)
    }
}
