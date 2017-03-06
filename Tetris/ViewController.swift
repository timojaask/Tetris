//  Created by Andy on 23/02/2017.
//  Copyright © 2017 Andy. All rights reserved.

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tetris: TetrisView! {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var pauseButton: UIButton!
    
    var field = Field() {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet var swipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
        
    func updateUI() {
        tetris.fieldWidth = field.width
        tetris.fieldHeight = field.height
        tetris.takenPositions.removeAll()
        for block in field.currentFigure + field.oldFigures {
            let position = (x: block.x, y: block.y)
            tetris.takenPositions += [position]
        }
        pauseButton.setTitle(field.inProgress() ? "Pause" : "Play", for: .normal)
    }
    
    @IBAction func dropFigure(_ sender: UISwipeGestureRecognizer) {
        field.tryToDrop()
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateUI), name: NSNotification.Name(rawValue: Field.modelUpdateNotification), object: nil)
        panGestureRecognizer.require(toFail: swipeGestureRecognizer)
        field.nextStep()
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
    
    @IBAction func togglePause() {
        if field.inProgress() {
            field.pause()
        } else {
            field.nextStep()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

