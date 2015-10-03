# DAExpandAnimation
A custom modal transition that presents a controller with an expanding effect while sliding out the presenter remnants.
# Screenshot
![DAExpandAnimation](https://raw.githubusercontent.com/ifitdoesntwork/DAExpandAnimation/master/Xpandr/screencapture.gif)
# Installation
Simply copy the `Xpandr/DAExpandAnimation.swift` file into your project.
# Usage
Try the example project!

Have your view controller conform to UIViewControllerTransitioningDelegate. Optionally set the `collapsedViewFrame`, the `expandedViewFrame` and the `animationDuration`.
```swift
private let animationController = DAExpandAnimation()

override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let toViewController = segue.destinationViewController
    
    if let selectedCell = sender as? UITableViewCell {
        toViewController.transitioningDelegate = self
        toViewController.modalPresentationStyle = .Custom
        toViewController.view.backgroundColor = selectedCell.backgroundColor
        
        animationController.collapsedViewFrame = {
            return selectedCell.frame
        }
        animationController.animationDuration = Constants.SomeAnimationDuration
        
        if let indexPath = tableView.indexPathForCell(selectedCell) {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
}
    
func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return animationController
}

func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return animationController
}
```
# Protocols

Adopting `DAExpandAnimationFromViewAnimationsAdapter` provides the following optional delegate methods for tailoring the presenter's UX.

```swift
// Does the animation require sliding the presenting view apart? Defaults to true.
optional var shouldSlideApart: Bool { get }

// Tweaks in the presenting view controller.
optional func animationsBeganInView(view: UIView, presenting isPresentation: Bool)
optional func animationsEnded(presenting isPresentation: Bool)
```
Adopting `DAExpandAnimationToViewAnimationsAdapter` provides the following optional delegate methods for tailoring the presentation of a new view controller.

```swift
// Additional setup before the animations.
optional func prepareExpandingView(view: UIView)
optional func prepareCollapsingView(view: UIView)

// Custom changes to animate.
optional func animationsForExpandingView(view: UIView)
optional func animationsForCollapsingView(view: UIView)

// Cleanup after the animations are performed.
optional func completionForExpandingView(view: UIView)
optional func completionForCollapsingView(view: UIView)
```
#MIT License

	Copyright (c) 2015 Denis Avdeev. All rights reserved.

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the "Software"),
	to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
