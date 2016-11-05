//
//  DAExpandAnimation.swift
//
//  Copyright (c) 2015 - 2016 Denis Avdeev. All rights reserved.
//        
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

class DAExpandAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    private struct Constants {
        static let systemAnimationDuration = 0.24
    }
    
    /// Updates `fromViewController` (the controller that is visible in
    /// the beginning of the transition) alongside the transition.
    weak var fromViewAnimationsAdapter: DAExpandAnimationFromViewAnimationsAdapter?
    
    /// Updates `toViewController` (the controller that is visible at
    /// the end of a completed transition) alongside the transition.
    weak var toViewAnimationsAdapter: DAExpandAnimationToViewAnimationsAdapter?
    
    /// Frame of the view to expand in presenter's view coordinates.
    /// Requires the current frame to deal with view size changes.
    var collapsedViewFrame: (() -> CGRect)?
    
    /// Desired final frame for the view in the window coordinates.
    /// When it is set to `nil` the view covers the whole window.
    var expandedViewFrame: CGRect?
    
    /// An approximation of the system modal view presentation duration.
    var animationDuration = Constants.systemAnimationDuration
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let isPresentation = toViewController.presentationController?.presentingViewController == fromViewController
        let backgroundView = (isPresentation ? fromViewController : toViewController).view!
        let frontView = (isPresentation ? toViewController : fromViewController).view!
        let inView = transitionContext.containerView
        
        // Figure the ad hoc collapsed and expanded view frames.
        backgroundView.layoutIfNeeded()
        var collapsedFrame = collapsedViewFrame?() ?? CGRect(
            x: backgroundView.bounds.origin.x,
            y: backgroundView.bounds.midY,
            width: backgroundView.bounds.width,
            height: 0
        )
        if collapsedFrame.maxY < backgroundView.bounds.origin.y {
            collapsedFrame.origin.y = backgroundView.bounds.origin.y - collapsedFrame.height
        }
        if collapsedFrame.origin.y > backgroundView.bounds.maxY {
            collapsedFrame.origin.y = backgroundView.bounds.maxY
        }
        let expandedFrame = expandedViewFrame ?? inView.bounds
        
        // Create the sliding views and add them to the scene.
        let topSlidingViewFrame = CGRect(
            x: backgroundView.bounds.origin.x,
            y: backgroundView.bounds.origin.y,
            width: backgroundView.bounds.width,
            height: collapsedFrame.origin.y
        )
        let topSlidingView = backgroundView.resizableSnapshotView(
            from: topSlidingViewFrame,
            afterScreenUpdates: false,
            withCapInsets: .zero
        )
        topSlidingView?.frame = topSlidingViewFrame
        
        let bottomSlidingViewOriginY = collapsedFrame.maxY
        let bottomSlidingViewFrame = CGRect(
            x: backgroundView.bounds.origin.x,
            y: bottomSlidingViewOriginY,
            width: backgroundView.bounds.width,
            height: backgroundView.bounds.maxY - bottomSlidingViewOriginY
        )
        let bottomSlidingView = backgroundView.resizableSnapshotView(
            from: bottomSlidingViewFrame,
            afterScreenUpdates: false,
            withCapInsets: .zero
        )
        bottomSlidingView?.frame = bottomSlidingViewFrame
        
        let topSlidingDistance = collapsedFrame.origin.y - backgroundView.bounds.origin.y
        let bottomSlidingDistance = backgroundView.bounds.maxY - collapsedFrame.maxY
        if !isPresentation {
            topSlidingView?.center.y -= topSlidingDistance
            bottomSlidingView?.center.y += bottomSlidingDistance
        }
        topSlidingView?.frame = backgroundView.convert(topSlidingView!.frame, to: inView)
        bottomSlidingView?.frame = backgroundView.convert(bottomSlidingView!.frame, to: inView)
        if !(fromViewAnimationsAdapter?.shouldSlideApart == false) && topSlidingView != nil && bottomSlidingView != nil {
            inView.addSubview(topSlidingView!)
            inView.addSubview(bottomSlidingView!)
        }
        
        // Add the expanding view to the scene.
        inView.addSubview(frontView)
        collapsedFrame = backgroundView.convert(collapsedFrame, to: inView)
        if isPresentation {
            frontView.frame = collapsedFrame
            toViewAnimationsAdapter?.prepare(expandingView: frontView)
        } else {
            toViewAnimationsAdapter?.prepare(collapsingView: frontView)
        }
        
        // Slide the cell views offscreen and expand the presented view.
        fromViewAnimationsAdapter?.animationsWillBegin(in: inView, presenting: isPresentation)
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                if isPresentation {
                    topSlidingView?.center.y -= topSlidingDistance
                    bottomSlidingView?.center.y += bottomSlidingDistance
                    frontView.frame = expandedFrame
                    frontView.layoutIfNeeded()
                    self.toViewAnimationsAdapter?.animateExpansion(within: frontView)
                } else {
                    topSlidingView?.center.y += topSlidingDistance
                    bottomSlidingView?.center.y -= bottomSlidingDistance
                    frontView.frame = collapsedFrame
                    self.toViewAnimationsAdapter?.animateCollapse(within: frontView)
                }
            },
            completion: { _ in
                topSlidingView?.removeFromSuperview()
                bottomSlidingView?.removeFromSuperview()
                if !isPresentation {
                    frontView.removeFromSuperview()
                }
                transitionContext.completeTransition(true)
                self.fromViewAnimationsAdapter?.animationsDidEnd(presenting: isPresentation)
                if isPresentation {
                    self.toViewAnimationsAdapter?.completeCollapse(within: frontView)
                } else {
                    self.toViewAnimationsAdapter?.completeCollapse(within: frontView)                }
            }
        )
    }
    
}

protocol DAExpandAnimationFromViewAnimationsAdapter: class {
    
    /// Does the animation require sliding the presenting view apart?
    /// Defaults to `true`.
    var shouldSlideApart: Bool { get }
    
    /// Notifies the presenting view controller that animations are about to occur.
    func animationsWillBegin(in view: UIView, presenting isPresentation: Bool)
    
    /// Notifies the presenting view controller that animations are just completed.
    func animationsDidEnd(presenting isPresentation: Bool)
    
}

protocol DAExpandAnimationToViewAnimationsAdapter: class {
    
    /// Gives the presented view controller a chance to prepare
    /// the expanding `view` before animation.
    func prepare(expandingView view: UIView)
    
    /// Gives the presented view controller a chance to prepare
    /// the collapsing `view` before animation.
    func prepare(collapsingView view: UIView)
    
    /// Gives the presented view controller ability to change
    /// properties of expanding `view` alongside the animation.
    func animateExpansion(within view: UIView)
    
    /// Gives the presented view controller ability to change
    /// properties of collapsing `view` alongside the animation.
    func animateCollapse(within view: UIView)
    
    /// Gives the presented view controller ability to
    /// clean `view` up after the expanding animation is performed.
    func completeExpansion(within view: UIView)
    
    /// Gives the presented view controller ability to
    /// clean `view` up after the collapsing animation is performed.
    func completeCollapse(within view: UIView)
    
}

// Default protocol implementations

extension DAExpandAnimationFromViewAnimationsAdapter {
    
    var shouldSlideApart: Bool { return true }
    func animationsWillBegin(in view: UIView, presenting isPresentation: Bool) {}
    func animationsDidEnd(presenting isPresentation: Bool) {}
    
}

extension DAExpandAnimationToViewAnimationsAdapter {
    
    func prepare(expandingView view: UIView) {}
    func prepare(collapsingView view: UIView) {}
    func animateExpansion(within view: UIView) {}
    func animateCollapse(within view: UIView) {}
    func completeExpansion(within view: UIView) {}
    func completeCollapse(within view: UIView) {}
    
}
