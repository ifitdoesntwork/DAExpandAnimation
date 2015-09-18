//
//  TableViewController.swift
//  Xpandr
//
//  Created by Denis Avdeev on 03.09.15.
//  Copyright (c) 2015 Denis Avdeev. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UIViewControllerTransitioningDelegate {

    private struct Constants {
        static let RowsCount = 20
        static let CellColors: [UIColor] = [
            .greenColor(),
            .blueColor(),
            .orangeColor(),
            .cyanColor(),
            .redColor(),
            .purpleColor(),
            .magentaColor(),
            .brownColor()
        ]
        static let DemoAnimationDuration = 1.0
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.RowsCount
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) 

        let colorIndex = indexPath.row % Constants.CellColors.count
        cell.backgroundColor = Constants.CellColors[colorIndex]

        return cell
    }

    // MARK: - Navigation

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
            animationController.animationDuration = Constants.DemoAnimationDuration
            
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

}
