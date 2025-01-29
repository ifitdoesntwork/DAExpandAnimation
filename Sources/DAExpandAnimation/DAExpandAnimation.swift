//
//  DAExpandAnimation.swift
//
//  Copyright (c) 2015 - 2025 Denis Avdeev. All rights reserved.
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

public class DAExpandAnimation: NSObject {
    
    /// The delegate for adapting the presenter's view to the transition.
    public weak var presentingViewAdapter: DAExpandAnimationPresentingViewAdapter?
    
    /// The delegate for adapting the presented view to the transition.
    public weak var presentedViewAdapter: DAExpandAnimationPresentedViewAdapter?
    
    /// The frame of the view to expand, in presenter's view coordinates.
    /// The closure is required to get the actual frame to collapse to.
    /// When set to `nil`, the view expands from the center of presenter's view.
    public var collapsedViewFrame: (() -> CGRect)?
    
    /// Desired final frame for the expanding view, in the window coordinates.
    /// When set to `nil`, the view covers the whole window.
    public var expandedViewFrame: CGRect?
    
    /// Creates a presenter's view top or bottom sliding part
    /// - Parameters:
    ///   - $0:  presenter's view
    ///   - $1:  sliding part frame, in presenter's view coordinates
    public var slidingPart: (UIView, CGRect) -> UIView? = {
        $0.resizableSnapshotView(
            from: $1,
            afterScreenUpdates: false,
            withCapInsets: .zero
        )
    }
    
    /// The total duration of the animations, measured in seconds.
    /// Defaults to an approximation of the system modal view presentation duration.
    public var animationDuration = 0.24
}

extension DAExpandAnimation: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        animationDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        let isPresentation = toViewController.presentationController?.presentingViewController == fromViewController
        let backgroundView = (isPresentation ? fromViewController : toViewController).view!
        let frontView = (isPresentation ? toViewController : fromViewController).view!
        let inView = transitionContext.containerView
        
        // Figure the actual collapsed and expanded view frames.
        backgroundView.layoutIfNeeded()
        var collapsedFrame = collapsedViewFrame?() ?? CGRect(
            x: backgroundView.bounds.origin.x,
            y: backgroundView.bounds.midY,
            width: backgroundView.bounds.width,
            height: .zero
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
            height: max(collapsedFrame.origin.y, backgroundView.bounds.origin.y)
        )
        let topSlidingView = slidingPart(backgroundView, topSlidingViewFrame)
        topSlidingView?.frame = topSlidingViewFrame
        
        let bottomSlidingViewOriginY = min(collapsedFrame.maxY, backgroundView.bounds.maxY)
        let bottomSlidingViewFrame = CGRect(
            x: backgroundView.bounds.origin.x,
            y: bottomSlidingViewOriginY,
            width: backgroundView.bounds.width,
            height: backgroundView.bounds.maxY - bottomSlidingViewOriginY
        )
        let bottomSlidingView = slidingPart(backgroundView, bottomSlidingViewFrame)
        bottomSlidingView?.frame = bottomSlidingViewFrame
        
        let topSlidingDistance = collapsedFrame.origin.y - backgroundView.bounds.origin.y
        let bottomSlidingDistance = backgroundView.bounds.maxY - collapsedFrame.maxY
        if !isPresentation {
            topSlidingView?.center.y -= topSlidingDistance
            bottomSlidingView?.center.y += bottomSlidingDistance
        }
        topSlidingView?.frame = backgroundView.convert(topSlidingView!.frame, to: inView)
        bottomSlidingView?.frame = backgroundView.convert(bottomSlidingView!.frame, to: inView)
        if presentingViewAdapter?.shouldSlideApart != false, let topSlidingView, let bottomSlidingView {
            inView.addSubview(topSlidingView)
            inView.addSubview(bottomSlidingView)
        }
        
        // Add the expanding view to the scene.
        inView.addSubview(frontView)
        collapsedFrame = backgroundView.convert(collapsedFrame, to: inView)
        if isPresentation {
            frontView.frame = collapsedFrame
            presentedViewAdapter?.prepare(expanding: frontView)
        } else {
            presentedViewAdapter?.prepare(collapsing: frontView)
        }
        
        // Slide the cell views offscreen and expand the presented view.
        presentingViewAdapter?.animationsWillBegin(in: inView, presenting: isPresentation)
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                if isPresentation {
                    topSlidingView?.center.y -= topSlidingDistance
                    bottomSlidingView?.center.y += bottomSlidingDistance
                    frontView.frame = expandedFrame
                    frontView.layoutIfNeeded()
                    self.presentedViewAdapter?.animate(expanding: frontView)
                } else {
                    topSlidingView?.center.y += topSlidingDistance
                    bottomSlidingView?.center.y -= bottomSlidingDistance
                    frontView.frame = collapsedFrame
                    self.presentedViewAdapter?.animate(collapsing: frontView)
                }
            },
            completion: { _ in
                topSlidingView?.removeFromSuperview()
                bottomSlidingView?.removeFromSuperview()
                if !isPresentation {
                    frontView.removeFromSuperview()
                }
                transitionContext.completeTransition(true)
                self.presentingViewAdapter?.animationsDidEnd(presenting: isPresentation)
                if isPresentation {
                    self.presentedViewAdapter?.cleanup(expanding: frontView)
                } else {
                    self.presentedViewAdapter?.cleanup(collapsing: frontView)
                }
            }
        )
    }
    
}

public protocol DAExpandAnimationPresentingViewAdapter: AnyObject {
    
    /// Determines whether the animations include sliding the presenter's view apart.
    /// Defaults to `true`.
    var shouldSlideApart: Bool { get }
    
    /// Notifies the presenter's view adapter that animations are about to occur.
    func animationsWillBegin(in view: UIView, presenting isPresentation: Bool)
    
    /// Notifies the presenter's view adapter that animations are just completed.
    func animationsDidEnd(presenting isPresentation: Bool)
    
}

public protocol DAExpandAnimationPresentedViewAdapter: AnyObject {
    
    /// Gives the presented view adapter a chance to prepare
    /// the expanding `view` before the animations.
    func prepare(expanding view: UIView)
    
    /// Gives the presented view adapter ability to change
    /// properties of the expanding `view` alongside the animations.
    func animate(expanding view: UIView)
    
    /// Gives the presented view adapter ability to clean the expanded `view` up
    /// after the animations are performed.
    func cleanup(expanding view: UIView)
    
    /// Gives the presented view adapter a chance to prepare
    /// the collapsing `view` before the animations.
    func prepare(collapsing view: UIView)
    
    /// Gives the presented view adapter ability to change
    /// properties of the collapsing `view` alongside the animations.
    func animate(collapsing view: UIView)
    
    /// Gives the presented view adapter ability to clean the collapsed `view`
    /// up after the animations are performed.
    func cleanup(collapsing view: UIView)
    
}

// Default protocol implementations

public extension DAExpandAnimationPresentingViewAdapter {
    
    var shouldSlideApart: Bool { true }
    func animationsWillBegin(in view: UIView, presenting isPresentation: Bool) {}
    func animationsDidEnd(presenting isPresentation: Bool) {}
    
}

public extension DAExpandAnimationPresentedViewAdapter {
    
    func prepare(expanding view: UIView) {}
    func animate(expanding view: UIView) {}
    func cleanup(expanding view: UIView) {}
    func prepare(collapsing view: UIView) {}
    func animate(collapsing view: UIView) {}
    func cleanup(collapsing view: UIView) {}
    
}
