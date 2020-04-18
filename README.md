# DAExpandAnimation
[![SPM supported](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager)
A custom modal transition that presents a controller with an expanding effect while sliding out the presenter remnants.
# Screenshot
![DAExpandAnimation](https://raw.githubusercontent.com/ifitdoesntwork/DAExpandAnimation/master/Xpandr/screencapture.gif)
# Installation
Simply copy the `Xpandr/DAExpandAnimation.swift` file into your project.
### Swift Package Manager
DAExpandAnimation is also available through [Swift Package Manager](https://github.com/apple/swift-package-manager/).
In Xcode select `File > Swift Packages > Add Package Dependency...` and type `DAExpandAnimation` in the search field.
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

Adopting `DAExpandAnimationPresentingViewAdapter` provides the following optional delegate methods for tailoring the presenter's UX.

```swift
/// A boolean value that determines whether the animations include sliding
/// the presenting view apart. Defaults to `true`.
var shouldSlideApart: Bool { get }

/// Notifies the presenting view adapter that animations are about to occur.
func animationsWillBegin(in view: UIView, presenting isPresentation: Bool)

/// Notifies the presenting view adapter that animations are just completed.
func animationsDidEnd(presenting isPresentation: Bool)
```
Adopting `DAExpandAnimationPresentedViewAdapter` provides the following optional delegate methods for tailoring the presentation of a new view controller.

```swift
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
```
# MIT License

	Copyright (c) 2015 - 2020 Denis Avdeev. All rights reserved.

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
