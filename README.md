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

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let toViewController = segue.destination
    
    if let selectedCell = sender as? UITableViewCell {
        toViewController.transitioningDelegate = self
        toViewController.modalPresentationStyle = .custom
        toViewController.view.backgroundColor = selectedCell.backgroundColor
        
        animationController.collapsedViewFrame = {
            return selectedCell.frame
        }
        animationController.animationDuration = Constants.someAnimationDuration
        
        if let indexPath = tableView.indexPath(for: selectedCell) {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}
    
func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return animationController
}

func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return animationController
}
```
# Protocols

Adopting `DAExpandAnimationFromViewAnimationsAdapter` provides the following optional delegate methods for tailoring the presenter's UX.

```swift
/// Does the animation require sliding the presenting view apart?
/// Defaults to `true`.
var shouldSlideApart: Bool { get }

/// Notifies the presenting view controller that animations are about to occur.
func animationsWillBegin(in view: UIView, presenting isPresentation: Bool)

/// Notifies the presenting view controller that animations are just completed.
func animationsDidEnd(presenting isPresentation: Bool)
```
Adopting `DAExpandAnimationToViewAnimationsAdapter` provides the following optional delegate methods for tailoring the presentation of a new view controller.

```swift
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
```
#MIT License

	Copyright (c) 2015 - 2016 Denis Avdeev. All rights reserved.

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
