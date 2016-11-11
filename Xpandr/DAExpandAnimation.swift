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
    
    /// The delegate for adapting the presenter's view to the transition.
    weak var presentingViewAdapter: DAExpandAnimationPresentingViewAdapter?
    
    /// The delegate for adapting the presented view to the transition.
    weak var presentedViewAdapter: DAExpandAnimationPresentedViewAdapter?
    
    /// The frame of the view to expand, in presenter's view coordinates.
    /// The closure is required to get the actual frame to collapse to.
    /// When set to `nil`, the view expands from the center of presenter's view.
    var collapsedViewFrame: (() -> CGRect)?
    
    /// Desired final frame for the expanding view, in the window coordinates.
    /// When set to `nil`, the view covers the whole window.
    var expandedViewFrame: CGRect?
    
    /// The total duration of the animations, measured in seconds. Set to an
    /// approximation of the system modal view presentation duration by default.
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
        
        // Figure the actual collapsed and expanded view frames.
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
        if !(presentingViewAdapter?.shouldSlideApart == false) && topSlidingView != nil && bottomSlidingView != nil {
            inView.addSubview(topSlidingView!)
            inView.addSubview(bottomSlidingView!)
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

protocol DAExpandAnimationPresentingViewAdapter: class {
    
    /// A boolean value that determines whether the animations include sliding
    /// the presenting view apart. Defaults to `true`.
    var shouldSlideApart: Bool { get }
    
    /// Notifies the presenting view adapter that animations are about to occur.
    func animationsWillBegin(in view: UIView, presenting isPresentation: Bool)
    
    /// Notifies the presenting view adapter that animations are just completed.
    func animationsDidEnd(presenting isPresentation: Bool)
    
}

protocol DAExpandAnimationPresentedViewAdapter: class {
    
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

extension DAExpandAnimationPresentingViewAdapter {
    
    var shouldSlideApart: Bool { return true }
    func animationsWillBegin(in view: UIView, presenting isPresentation: Bool) {}
    func animationsDidEnd(presenting isPresentation: Bool) {}
    
}

extension DAExpandAnimationPresentedViewAdapter {
    
    func prepare(expanding view: UIView) {}
    func animate(expanding view: UIView) {}
    func cleanup(expanding view: UIView) {}
    func prepare(collapsing view: UIView) {}
    func animate(collapsing view: UIView) {}
    func cleanup(collapsing view: UIView) {}
    
}
