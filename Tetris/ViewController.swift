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
        for block in field.currentFigure.blocks + field.oldFigures {
            let position = (x: block.x, y: block.y)
            tetris.takenPositions += [position]
        }
        pauseButton.setTitle(field.inProgress() ? "Pause" : "Play", for: .normal)
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateUI), name: NSNotification.Name(rawValue: Field.modelUpdateNotification), object: nil)
        field.nextStep()
    }
    
    @IBAction func slideFigure(_ sender: UIPanGestureRecognizer) {
        if field.inProgress() {
            switch sender.state {
            case .ended:
                let verticalVelocity = sender.velocity(in: tetris).y
                let swipeVelocity = CGFloat(1000.0)
                if verticalVelocity > swipeVelocity {
                    field.tryToDrop()
                }
            case .changed:
                var translation = sender.translation(in: tetris)
                
                let coefficient = CGFloat(0.6)
                
                let xSteps = Int(translation.x / tetris.blockSize / coefficient)
                let ySteps = Int(translation.y / tetris.blockSize / coefficient)
                
                if xSteps != 0 {
                    field.tryToSlide(xSteps > 0 ? .Right : .Left, steps: abs(xSteps))
                    translation.x = 0
                    sender.setTranslation(translation, in: tetris)
                }
                if ySteps > 0 {
                    field.tryToSlide(.Down, steps: ySteps)
                    translation.y = 0
                } else if ySteps < 0 {
                    translation.y = 0
                }
                
                sender.setTranslation(translation, in: tetris)
            default:
                break
            }
        }
    }
    
    @IBAction func rotateFigure(_ sender: Any) {
        if field.inProgress() {
            field.rotateFigure()
        }
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

