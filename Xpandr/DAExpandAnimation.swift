//
//  DAExpandAnimation.swift
//
//  Copyright (c) 2015 Denis Avdeev. All rights reserved.
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
        static let SystemAnimationDuration = 0.24
    }
    
    // Update fromViewController (the controller that is visible in the beginning of the transition) alongside the transition.
    var fromViewAnimationsAdapter: DAExpandAnimationFromViewAnimationsAdapter?
    
    // Update toViewController (the controller that is visible at the end of a completed transition) alongside the transition.
    var toViewAnimationsAdapter: DAExpandAnimationToViewAnimationsAdapter?
    
    // Frame of the view to expand in presenter's view coordinates. Requires the current frame to deal with view size changes.
    var collapsedViewFrame: (() -> CGRect)?
    
    // Desired final frame for the view in the window coordinates. When it is set to nil the view covers the whole window.
    var expandedViewFrame: CGRect?
    
    // Default animation duration is an approximation of the system modal view presentation duration.
    var animationDuration = Constants.SystemAnimationDuration
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let isPresentation = toViewController.presentationController?.presentingViewController == fromViewController
        let backgroundView = (isPresentation ? fromViewController : toViewController).view
        let frontView = (isPresentation ? toViewController : fromViewController).view
        guard let inView = transitionContext.containerView() else { return }
        
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
        let topSlidingView = backgroundView.resizableSnapshotViewFromRect(
            topSlidingViewFrame,
            afterScreenUpdates: false,
            withCapInsets: UIEdgeInsetsZero
        )
        topSlidingView.frame = topSlidingViewFrame
        
        let bottomSlidingViewOriginY = collapsedFrame.maxY
        let bottomSlidingViewFrame = CGRect(
            x: backgroundView.bounds.origin.x,
            y: bottomSlidingViewOriginY,
            width: backgroundView.bounds.width,
            height: backgroundView.bounds.maxY - bottomSlidingViewOriginY
        )
        let bottomSlidingView = backgroundView.resizableSnapshotViewFromRect(
            bottomSlidingViewFrame,
            afterScreenUpdates: false,
            withCapInsets: UIEdgeInsetsZero
        )
        bottomSlidingView.frame = bottomSlidingViewFrame
        
        let topSlidingDistance = collapsedFrame.origin.y - backgroundView.bounds.origin.y
        let bottomSlidingDistance = backgroundView.bounds.maxY - collapsedFrame.maxY
        if !isPresentation {
            topSlidingView.center.y -= topSlidingDistance
            bottomSlidingView.center.y += bottomSlidingDistance
        }
        topSlidingView.frame = backgroundView.convertRect(topSlidingView.frame, toView: inView)
        bottomSlidingView.frame = backgroundView.convertRect(bottomSlidingView.frame, toView: inView)
        if !(fromViewAnimationsAdapter?.shouldSlideApart == false) {
            inView.addSubview(topSlidingView)
            inView.addSubview(bottomSlidingView)
        }
        
        // Add the expanding view to the scene.
        collapsedFrame = backgroundView.convertRect(collapsedFrame, toView: inView)
        if isPresentation {
            frontView.frame = collapsedFrame
            toViewAnimationsAdapter?.prepareExpandingView?(frontView)
        } else {
            toViewAnimationsAdapter?.prepareCollapsingView?(frontView)
        }
        inView.addSubview(frontView)
        
        // Slide the cell views offscreen and expand the presented view.
        fromViewAnimationsAdapter?.animationsBeganInView?(inView, presenting: isPresentation)
        UIView.animateWithDuration(
            transitionDuration(transitionContext),
            animations: {
                if isPresentation {
                    topSlidingView.center.y -= topSlidingDistance
                    bottomSlidingView.center.y += bottomSlidingDistance
                    frontView.frame = expandedFrame
                    frontView.layoutIfNeeded()
                    self.toViewAnimationsAdapter?.animationsForExpandingView?(frontView)
                } else {
                    topSlidingView.center.y += topSlidingDistance
                    bottomSlidingView.center.y -= bottomSlidingDistance
                    frontView.frame = collapsedFrame
                    self.toViewAnimationsAdapter?.animationsForCollapsingView?(frontView)
                }
            },
            completion: { _ in
                topSlidingView.removeFromSuperview()
                bottomSlidingView.removeFromSuperview()
                if !isPresentation {
                    frontView.removeFromSuperview()
                }
                transitionContext.completeTransition(true)
                self.fromViewAnimationsAdapter?.animationsEnded?(presenting: isPresentation)
                if isPresentation {
                    self.toViewAnimationsAdapter?.completionForExpandingView?(frontView)
                } else {
                    self.toViewAnimationsAdapter?.completionForCollapsingView?(frontView)
                }
            }
        )
    }
    
}

@objc protocol DAExpandAnimationFromViewAnimationsAdapter {
    
    // Does the animation require sliding the presenting view apart? Defaults to false.
    optional var shouldSlideApart: Bool { get }
    
    // Tweaks in the presenting view controller.
    optional func animationsBeganInView(view: UIView, presenting isPresentation: Bool)
    optional func animationsEnded(presenting isPresentation: Bool)
    
}

@objc protocol DAExpandAnimationToViewAnimationsAdapter {
    
    // Additional setup before the animations.
    optional func prepareExpandingView(view: UIView)
    optional func prepareCollapsingView(view: UIView)
    
    // Custom changes to animate.
    optional func animationsForExpandingView(view: UIView)
    optional func animationsForCollapsingView(view: UIView)
    
    // Cleanup after the animations are performed.
    optional func completionForExpandingView(view: UIView)
    optional func completionForCollapsingView(view: UIView)
    
}
