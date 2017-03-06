//  Created by Andy on 04/03/2017.
//  Copyright © 2017 Andy. All rights reserved.

import Foundation

class Field: NSObject {
    override init() {
        super.init()
        spawnFigure()
    }

    static let modelUpdateNotification = "dataModelDidUpdateNotification"
    
    var width = 12
    var height = 20
    
    private var stepInterval = 1.0
    
    private var timer: Timer? = nil
    
    func nextStep() {
        timer = Timer.scheduledTimer(timeInterval: stepInterval, target:self, selector: #selector(Field.moveDown), userInfo: nil, repeats: false)
        modelChanged()
    }
    
    func pause() {
        if timer != nil {
            timer!.invalidate()
        }
        modelChanged()
    }
    
    func inProgress() -> Bool {
        return timer != nil && timer!.isValid
    }

    func reset() {
        if inProgress() {
            timer!.invalidate()
        }
        spawnFigure()
        oldFigures = []
        nextStep()
        modelChanged()
    }
    
    func tryToSlide(steps: Int) {
        var stepsToMove = 0
        
        for i in 1...abs(steps) {
            let step = i * (steps > 0 ? 1 : -1)
            
            var canMove = true
            
            for block in currentFigure {
                let newPositionX = block.positionX + step
                if newPositionX < 0 || newPositionX >= width {
                    canMove = false
                    break
                }
                if oldFigures.contains(Block(x:newPositionX, y:block.positionY)) {
                    canMove = false
                    break
                }
            }
            
            if canMove {
                stepsToMove = step
            } else {
                break
            }
        }
        
        if stepsToMove != 0 {
            for block in currentFigure {
                block.positionX += stepsToMove
            }
            modelChanged()
        }        
    }
    
    func tryToDrop() {
        // Simple code for now
        while tryToMoveCurrentFigureDown() {
        }
    }
    
    func rotateFigure() {
        if currentFigureCenter == nil {
            return
        }
        
        let newFigure = currentFigure.map{ Block(x: $0.positionX, y: $0.positionY) }
        let newFigureCenter = newFigure[currentFigure.index(of: currentFigureCenter!)!]
        
        for block in newFigure {
            if block == currentFigureCenter {                
                continue
            }
            
            let xDifference = currentFigureCenter!.positionX - block.positionX
            let yDifference = currentFigureCenter!.positionY - block.positionY
            
            block.positionX = currentFigureCenter!.positionX + yDifference
            block.positionY = currentFigureCenter!.positionY - xDifference
            
            if oldFigures.contains(block) || block.positionX < 0 || block.positionX >= width || block.positionY < 0 || block.positionY >= height {
                return
            }
        }
        
        currentFigure = newFigure
        currentFigureCenter = newFigureCenter
        
        modelChanged()
    }
    
    @objc private func moveDown() {
        if !tryToMoveCurrentFigureDown() {
            spawnFigure()
        }
        nextStep()
    }
    
    private func tryToMoveCurrentFigureDown() -> Bool {
        for block in currentFigure {
            let newPositionY = block.positionY + 1
            if newPositionY == height {
                return false
            }
            
            if oldFigures.contains(Block(x: block.positionX, y: newPositionY)) {
                return false
            }
        }
        
        for block in currentFigure {
            block.positionY += 1
        }
        
        modelChanged()
        
        return true
    }
    
    enum Shape: UInt32 {
        case S = 0
        case ReverseS
        case Beam
        case Square
        case Tee
    }
    
    private func spawnFigure() {
        for block in currentFigure {
            oldFigures.insert(block)
        }
        
        let shapeIndex = arc4random_uniform(Shape.Tee.rawValue+1)
        let centerX = width / 2 - 1
        let centerY = 1
        if let shape = Shape(rawValue: shapeIndex) {
            switch shape
            {
            case .S:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = [currentFigureCenter!,
                                 Block(x: centerX, y: centerY-1),
                                 Block(x: centerX+1, y: centerY),
                                 Block(x: centerX+1, y: centerY+1)]
            case .ReverseS:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = [currentFigureCenter!,
                                 Block(x: centerX+1, y: centerY-1),
                                 Block(x: centerX+1, y: centerY),
                                 Block(x: centerX, y: centerY+1)]
            case .Beam:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = [currentFigureCenter!,
                                 Block(x: centerX, y: centerY-1),
                                 Block(x: centerX, y: centerY+1),
                                 Block(x: centerX, y: centerY+2)]
            case .Square:
                currentFigureCenter = nil
                currentFigure = [Block(x: centerX, y: centerY),
                                 Block(x: centerX+1, y: centerY-1),
                                 Block(x: centerX+1, y: centerY),
                                 Block(x: centerX, y: centerY-1)]
            case .Tee:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = [currentFigureCenter!,
                                 Block(x: centerX-1, y: centerY),
                                 Block(x: centerX, y: centerY-1),
                                 Block(x: centerX+1, y: centerY)]
            }
        }
        
        modelChanged()
    }
    
    private func modelChanged() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Field.modelUpdateNotification), object: nil)
    }
    
    private(set) var currentFigure: [Block] = []
    private var currentFigureCenter: Block? = nil
    
    private(set) var oldFigures = Set<Block>()
}
