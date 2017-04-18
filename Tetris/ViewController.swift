//  Created by Andy on 23/02/2017.
//  Copyright © 2017 Andy. All rights reserved.

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tetris: TetrisView! 
    
    @IBOutlet weak var pauseButton: UIButton!
    
    var field = Field()
    
    var gameOverView: UIView? = nil
    
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
        
        if field.gameOver && gameOverView == nil {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
            
            gameOverView = UIVisualEffectView(effect: blurEffect)
            gameOverView!.frame = self.view.bounds
            gameOverView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(gameOverView!)
            
            let label = UILabel()
            label.text = "GAME OVER"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 35)
            label.frame = gameOverView!.bounds
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            gameOverView!.addSubview(label)
            
            let button = UIButton()
            button.setTitle("Start again", for: .normal)
            button.setTitleColor(UIColor.blue, for: .normal)
            button.sizeToFit()
            button.addTarget(self, action: #selector(reset), for: .touchUpInside)
            
            gameOverView!.addSubview(button)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            button.translatesAutoresizingMaskIntoConstraints = false
            
            label.centerXAnchor.constraint(equalTo: gameOverView!.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: gameOverView!.centerYAnchor).isActive = true
            
            button.topAnchor.constraint(equalTo: label.layoutMarginsGuide.bottomAnchor, constant: 100.0).isActive = true
            button.centerXAnchor.constraint(equalTo: gameOverView!.centerXAnchor).isActive = true
        } else if !field.gameOver && gameOverView != nil {
            gameOverView!.removeFromSuperview()
            gameOverView = nil
        }
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateUI), name: NSNotification.Name(rawValue: Field.modelUpdateNotification), object: nil)
        field.nextStep()
    }
    
    @IBAction func slideFigure(_ sender: UIPanGestureRecognizer) {
        if field.inProgress() {
            switch sender.state {
            case .ended:
                let horizontalVelocity = sender.velocity(in: tetris).x
                let verticalVelocity = sender.velocity(in: tetris).y
                let swipeVelocity = CGFloat(1000.0)
                if verticalVelocity > swipeVelocity && abs(horizontalVelocity) < swipeVelocity {
                    field.tryToDrop()
                }
            case .changed:
                var translation = sender.translation(in: tetris)
                
                let coefficient = CGFloat(0.6)
                
                let xSteps = Int(translation.x / tetris.blockSize / coefficient)
                let ySteps = Int(translation.y / tetris.blockSize / coefficient)

                if xSteps != 0 && abs(xSteps) > abs(ySteps) {
                    field.tryToSlide(xSteps > 0 ? .Right : .Left, steps: abs(xSteps))
                    translation = CGPoint.zero
                    sender.setTranslation(translation, in: tetris)
                } else {
                    if ySteps > 0 {
                        field.tryToSlide(.Down, steps: ySteps)
                        translation = CGPoint.zero
                    } else if ySteps < 0 {
                        translation = CGPoint.zero
                    }
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

