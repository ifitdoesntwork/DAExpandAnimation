//
//  TableViewController.swift
//  Xpandr
//
//  Created by Denis Avdeev on 03.09.15.
//  Copyright (c) 2015 - 2021 Denis Avdeev. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UIViewControllerTransitioningDelegate {

    private struct Constants {
        static let rowsCount = 20
        static let cellColors: [UIColor] = [
            .systemGreen,
            .systemBlue,
            .systemOrange,
            .brown,
            .systemRed,
            .systemYellow,
            .systemTeal,
            .systemPink
        ]
        static let demoAnimationDuration = 1.0
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.rowsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) 

        let colorIndex = indexPath.row % Constants.cellColors.count
        cell.backgroundColor = Constants.cellColors[colorIndex]

        return cell
    }

    // MARK: - Navigation

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
            animationController.animationDuration = Constants.demoAnimationDuration
            
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

}
