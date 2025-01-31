[![SPM supported](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager)
# DAExpandAnimation
A custom modal transition that presents a controller with an expanding effect while sliding out the presenter remnants.
# Screenshot
![DAExpandAnimation](https://raw.githubusercontent.com/ifitdoesntwork/DAExpandAnimation/master/Example/screencapture.gif)
# Installation
Simply copy the `Sources/DAExpandAnimation/DAExpandAnimation.swift` file into your project.
### Swift Package Manager
DAExpandAnimation is also available through [Swift Package Manager](https://github.com/apple/swift-package-manager/).
```swift
.package(url: "https://github.com/ifitdoesntwork/DAExpandAnimation.git", from: "1.0.0")
```
# Usage
Try the example project!

Have your view controller conform to UIViewControllerTransitioningDelegate. Optionally set the `collapsedViewFrame`, the `expandedViewFrame`, the `slidingPart` and the `animationDuration`.
```swift
private let animationController = DAExpandAnimation()

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let selectedCell = sender as? UITableViewCell else {
        return
    }
    
    let toViewController = segue.destination
    toViewController.transitioningDelegate = self
    toViewController.modalPresentationStyle = .custom
    toViewController.view.backgroundColor = selectedCell.backgroundColor
    
    animationController.collapsedViewFrame = {
        selectedCell.frame
    }
    animationController.animationDuration = Constants.demoAnimationDuration()
}
    
func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    animationController
}

func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    animationController
}
```
# Protocols

Adopting `DAExpandAnimationPresentingViewAdapter` provides the following optional delegate methods for tailoring the presenter's UX.

```swift
/// Determines whether the animations include sliding the presenter's view apart.
/// Defaults to `true`.
var shouldSlideApart: Bool { get }

/// Notifies the presenter's view adapter that animations are about to occur.
func animationsWillBegin(in view: UIView, presenting isPresentation: Bool)

/// Notifies the presenter's view adapter that animations are just completed.
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
