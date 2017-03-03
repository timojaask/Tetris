//
//  ViewController.swift
//  Tetris
//
//  Created by Andy on 23/02/2017.
//  Copyright © 2017 Andy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tetris: TetrisView!
    
    @IBAction func dropFigure(_ sender: UISwipeGestureRecognizer) {
        tetris.dropFigure()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

