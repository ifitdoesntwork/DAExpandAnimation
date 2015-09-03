//
//  DAExpandAnimation.swift
//  Xpandr
//
//  Created by Denis Avdeev on 03.09.15.
//  Copyright (c) 2015 Denis Avdeev. All rights reserved.
//

import UIKit

class DAExpandAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    private struct Constants {
        static let SystemAnimationDuration = 0.24
    }
    
    // Update fromViewController (the controller that is visible in the beginning of the transition) alongside the transition.
    var fromViewAnimationsAdapter: DAExpandAnimationFromViewAnimationsAdapter?
    
    // Update toViewController (the controller that is visible at the end of a completed transition) alongside the transition.
    var toViewAnimationsAdapter: DAExpandAnimationToViewAnimationsAdapter?
    
    // Frame of the view to expand in fromView coordinates. Requires the current frame to deal with view size changes.
    var collapsedViewFrame: (() -> CGRect)?
    
    // Desired final frame for the view. When it is set to nil the view covers the whole window.
    var expandedViewFrame: CGRect?
    
    // Default animation duration is an approximation of the system modal view presentation duration.
    var animationDuration = Constants.SystemAnimationDuration
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let inView = transitionContext.containerView()
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let isPresentation = toViewController.presentationController?.presentingViewController == fromViewController
        
        // Set the scene.
        toView?.layoutIfNeeded()
        var collapsedFrame = collapsedViewFrame?() ?? CGRect(
            x: 0,
            y: inView.bounds.height / 2,
            width: inView.bounds.width,
            height: 0
        )
        if collapsedFrame.maxY < 0 {
            collapsedFrame.origin.y = -collapsedFrame.height
        }
        if collapsedFrame.origin.y > inView.bounds.height {
            collapsedFrame.origin.y = inView.bounds.height
        }
        
        // Create the sliding views and add them to the scene.
        let backgroundViewController = isPresentation ? fromViewController : toViewController
        let topSlidingViewFrame = CGRect(
            x: backgroundViewController.view.bounds.origin.x,
            y: backgroundViewController.view.bounds.origin.y,
            width: collapsedFrame.width,
            height: collapsedFrame.origin.y
        )
        let topSlidingView = backgroundViewController.view.resizableSnapshotViewFromRect(
            topSlidingViewFrame,
            afterScreenUpdates: false,
            withCapInsets: UIEdgeInsetsZero
        )
        let bottomViewOriginY = collapsedFrame.maxY
        var bottomSlidingViewFrame = CGRect(
            x: backgroundViewController.view.bounds.origin.x,
            y: backgroundViewController.view.bounds.origin.y + bottomViewOriginY,
            width: collapsedFrame.width,
            height: inView.bounds.height - bottomViewOriginY
        )
        let bottomSlidingView = backgroundViewController.view.resizableSnapshotViewFromRect(
            bottomSlidingViewFrame,
            afterScreenUpdates: false,
            withCapInsets: UIEdgeInsetsZero
        )
        bottomSlidingViewFrame.origin.y -= backgroundViewController.view.bounds.origin.y
        bottomSlidingView.frame = bottomSlidingViewFrame
        let topSlidingDistance = collapsedFrame.origin.y
        let bottomSlidingDistance = inView.bounds.height - collapsedFrame.height - topSlidingDistance
        if !isPresentation {
            topSlidingView.center.y -= topSlidingDistance
            bottomSlidingView.center.y += bottomSlidingDistance
        }
        if !(fromViewAnimationsAdapter?.shouldSlideApart == false) {
            inView.addSubview(topSlidingView)
            inView.addSubview(bottomSlidingView)
        }
        
        // Add the expanding view to the scene.
        let finalFrame = expandedViewFrame ?? toViewController.view.frame
        if isPresentation {
            toView!.frame = collapsedFrame
            toViewAnimationsAdapter?.prepareExpandingView(toView!)
            inView.addSubview(toView!)
        } else {
            toViewAnimationsAdapter?.prepareCollapsingView(fromView!)
            inView.addSubview(fromView!)
        }
        
        // Slide the cell views offscreen and expand the presented view.
        fromViewAnimationsAdapter?.animationsBeganInView(inView, presenting: isPresentation)
        UIView.animateWithDuration(
            transitionDuration(transitionContext),
            animations: {
                if isPresentation {
                    topSlidingView.center.y -= topSlidingDistance
                    bottomSlidingView.center.y += bottomSlidingDistance
                    toView!.frame = finalFrame
                    toView!.layoutIfNeeded()
                    self.toViewAnimationsAdapter?.animationsForExpandingView(toView!)
                } else {
                    topSlidingView.center.y += topSlidingDistance
                    bottomSlidingView.center.y -= bottomSlidingDistance
                    fromView!.frame = collapsedFrame
                    self.toViewAnimationsAdapter?.animationsForCollapsingView(fromView!)
                }
            },
            completion: { _ in
                topSlidingView.removeFromSuperview()
                bottomSlidingView.removeFromSuperview()
                if !isPresentation {
                    fromView?.removeFromSuperview()
                    toView?.removeFromSuperview()
                }
                transitionContext.completeTransition(true)
                self.fromViewAnimationsAdapter?.animationsEnded(presenting: isPresentation)
                if isPresentation {
                    self.toViewAnimationsAdapter?.completionForExpandingView(toView!)
                } else {
                    self.toViewAnimationsAdapter?.completionForCollapsingView(fromView!)
                }
            }
        )
    }
    
}

protocol DAExpandAnimationFromViewAnimationsAdapter {
    
    // Does the animation require sliding the presenting view apart?
    var shouldSlideApart: Bool { get }
    
    // Tweaks in the presenting view controller.
    func animationsBeganInView(view: UIView, presenting isPresentation: Bool)
    func animationsEnded(presenting isPresentation: Bool)
    
}

protocol DAExpandAnimationToViewAnimationsAdapter {
    
    // Additional setup before the animations.
    func prepareExpandingView(view: UIView)
    func prepareCollapsingView(view: UIView)
    
    // Custom changes to animate.
    func animationsForExpandingView(view: UIView)
    func animationsForCollapsingView(view: UIView)
    
    // Cleanup after the animations are performed.
    func completionForExpandingView(view: UIView)
    func completionForCollapsingView(view: UIView)
    
}
