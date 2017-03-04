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
    
    private var stepInterval = 1.0
    
    @IBAction func dropFigure(_ sender: UISwipeGestureRecognizer) {
        tetris.dropFigure()
    }
    
    override func viewDidLoad() {
        tetris.timer = Timer.scheduledTimer(timeInterval: stepInterval, target:tetris, selector: #selector(TetrisView.moveDown), userInfo: nil, repeats: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

