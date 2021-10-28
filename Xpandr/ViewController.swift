//
//  ViewController.swift
//  Xpandr
//
//  Created by Denis Avdeev on 03.09.15.
//  Copyright (c) 2015 - 2021 Denis Avdeev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func dismiss(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            dismiss(animated: true, completion: nil)
        }
    }

}

