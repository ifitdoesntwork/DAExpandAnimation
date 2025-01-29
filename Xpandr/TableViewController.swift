//
//  TableViewController.swift
//  Xpandr
//
//  Created by Denis Avdeev on 03.09.15.
//  Copyright (c) 2015 - 2021 Denis Avdeev. All rights reserved.
//

import DAExpandAnimation
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
        static let demoAnimationDuration = {
            Double.random(in: 0.1...1)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Constants.rowsCount
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

}
