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
    
    private var panOriginX: CGFloat?
    
    @IBAction func slideFigure(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case UIGestureRecognizerState.began:
            panOriginX = 0
        case UIGestureRecognizerState.changed:
            if panOriginX == nil {
                return
            }
            
            let currentX = sender.translation(in: tetris).x
            let difference = currentX - panOriginX!
            
            let steps = Int(difference / tetris.blockSize / 0.6)
            if steps != 0 {
                panOriginX = currentX
                field.tryToSlide(steps: steps)
            }
        case UIGestureRecognizerState.ended:
            panOriginX = nil
        default:
            break
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        field.reset()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

