//
//  ViewController.swift
//  Tetris
//
//  Created by Andy on 23/02/2017.
//  Copyright © 2017 Andy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tetris: TetrisView! {
        didSet {
            updateUI()
        }
    }
    
    var field = Field() {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet var swipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    private var stepInterval = 1.0
    var timer = Timer()
    
    func updateUI() {
        tetris.fieldWidth = field.width
        tetris.fieldHeight = field.height
        tetris.takenPositions.removeAll()
        for block in field.currentFigure + field.oldFigures {
            let position = (x:block.positionX, y:block.positionY)
            tetris.takenPositions += [position]
        }
    }
    
    @IBAction func dropFigure(_ sender: UISwipeGestureRecognizer) {
        field.tryToDrop()
    }
    
    override func viewDidLoad() {
        timer = Timer.scheduledTimer(timeInterval: stepInterval, target:self, selector: #selector(ViewController.moveDown), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateUI), name: NSNotification.Name(rawValue: Field.modelUpdateNotification), object: nil)
        panGestureRecognizer.require(toFail: swipeGestureRecognizer)
    }
    
    func moveDown() {
        field.moveDown()
    }
    
    @IBAction func slideFigure(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case UIGestureRecognizerState.changed:
            let horizontalDistance = sender.translation(in: tetris).x
            
            let steps = Int(horizontalDistance / tetris.blockSize / 0.6)
            if steps != 0 {
                field.tryToSlide(steps: steps)
                sender.setTranslation(CGPoint.zero, in: tetris)
            }
        default:
            break
        }
    }
    
    @IBAction func rotateFigure(_ sender: Any) {
        field.rotateFigure()
    }
    
    @IBAction func reset(_ sender: Any) {
        field.reset()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

