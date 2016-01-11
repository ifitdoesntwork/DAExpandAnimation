//
//  ViewController.swift
//  Xpandr
//
//  Created by Denis Avdeev on 03.09.15.
//  Copyright (c) 2015 - 2016 Denis Avdeev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func dismiss(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

}

