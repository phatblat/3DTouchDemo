//
//  ForceProgressViewController.swift
//  3DTouchDemo
//
//  Created by Ben Chatelain on 10/4/15.
//  Copyright © 2015 Ben Chatelain. All rights reserved.
//

import UIKit

/// An implementation of Bite #95 from Little Bites of Cocoa
/// https://littlebitesofcocoa.com/95
class ForceProgressViewController: UIViewController {

    @IBOutlet var progressView: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()

        progressView.progress = 0.0
    }

}

// MARK: - UIResponder

extension ForceProgressViewController {

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)

        guard #available(iOS 9.0, *) else { return }

        updateForTouches(touches)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)

        guard #available(iOS 9.0, *) else { return }

        updateForTouches(touches)
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)

        guard #available(iOS 9.0, *) else { return }

        updateForTouches(touches)
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)

        guard #available(iOS 9.0, *) else { return }

        updateForTouches(touches)
    }

}

// MARK: - Private

@available(iOS 9.0, *)
extension ForceProgressViewController {
    
    private func updateForTouches(touches: Set<UITouch>?) {
        guard traitCollection.forceTouchCapability == .Available else { return }

        var force: Float = 0.0

        if let touches = touches, let touch = touches.first {
            force = Float(touch.force / touch.maximumPossibleForce)
        }

        progressView.progress = force
        view.backgroundColor = UIColor.redColor().colorWithAlphaComponent(CGFloat(force))
    }

}
