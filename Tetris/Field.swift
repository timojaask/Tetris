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
                let newX = block.x + step
                if newX < 0 || newX >= width {
                    canMove = false
                    break
                }
                if oldFigures.contains(Block(x:newX, y:block.y)) {
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
                block.x += stepsToMove
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
        
        let newFigure = currentFigure.map{ Block(x: $0.x, y: $0.y) }
        let newFigureCenter = newFigure[currentFigure.index(of: currentFigureCenter!)!]
        
        for block in newFigure {
            if block == currentFigureCenter {                
                continue
            }
            
            let xDifference = currentFigureCenter!.x - block.x
            let yDifference = currentFigureCenter!.y - block.y
            
            block.x = currentFigureCenter!.x + yDifference
            block.y = currentFigureCenter!.y - xDifference
            
            if oldFigures.contains(block) || block.x < 0 || block.x >= width || block.y < 0 || block.y >= height {
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
            removeFilledRows()
        }
        nextStep()
    }
    
    private func tryToMoveCurrentFigureDown() -> Bool {
        for block in currentFigure {
            let newY = block.y + 1
            if newY == height {
                return false
            }
            
            if oldFigures.contains(Block(x: block.x, y: newY)) {
                return false
            }
        }
        
        for block in currentFigure {
            block.y += 1
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
        case L
        case J
    }
    
    private func spawnFigure() {
        for block in currentFigure {
            oldFigures.insert(block)
        }
        
        let shapeIndex = arc4random_uniform(Shape.J.rawValue+1)
        let centerX = width / 2 - 1
        let centerY = 1
        if let shape = Shape(rawValue: shapeIndex) {
            switch shape
            {
            case .S:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = [currentFigureCenter!,
                                 Block(x: centerX,      y: centerY-1),
                                 Block(x: centerX+1,    y: centerY),
                                 Block(x: centerX+1,    y: centerY+1)]
            case .ReverseS:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = [currentFigureCenter!,
                                 Block(x: centerX+1,    y: centerY-1),
                                 Block(x: centerX+1,    y: centerY),
                                 Block(x: centerX,      y: centerY+1)]
            case .Beam:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = [currentFigureCenter!,
                                 Block(x: centerX,      y: centerY-1),
                                 Block(x: centerX,      y: centerY+1),
                                 Block(x: centerX,      y: centerY+2)]
            case .Square:
                currentFigureCenter = nil
                currentFigure = [Block(x: centerX,      y: centerY),
                                 Block(x: centerX+1,    y: centerY-1),
                                 Block(x: centerX+1,    y: centerY),
                                 Block(x: centerX,      y: centerY-1)]
            case .Tee:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = [currentFigureCenter!,
                                 Block(x: centerX-1,    y: centerY),
                                 Block(x: centerX,      y: centerY-1),
                                 Block(x: centerX+1,    y: centerY)]
            case .L:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = [currentFigureCenter!,
                                 Block(x: centerX,      y: centerY-1),
                                 Block(x: centerX,      y: centerY+1),
                                 Block(x: centerX+1,    y: centerY+1)]
            case .J:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = [currentFigureCenter!,
                                 Block(x: centerX,      y: centerY-1),
                                 Block(x: centerX,      y: centerY+1),
                                 Block(x: centerX-1,    y: centerY+1)]
            }
        }
        
        modelChanged()
    }
    
    private func removeFilledRows() {
        var numberOfRemovedRows = 0
        
        for row in (0..<height).reversed() {
            let blocksInTheRow = Set(oldFigures.filter { $0.y == row })
            if blocksInTheRow.count == width {
                oldFigures.subtract(blocksInTheRow)
                numberOfRemovedRows += 1
            }
            else if numberOfRemovedRows > 0 {
                // We can't just modify the item, Set<Block> goes crazy
                oldFigures.subtract(blocksInTheRow)
                blocksInTheRow.forEach{ $0.y += numberOfRemovedRows }
                oldFigures.formUnion(blocksInTheRow)
            }
        }
    }
    
    private func modelChanged() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Field.modelUpdateNotification), object: nil)
    }
    
    private(set) var currentFigure: [Block] = []
    private var currentFigureCenter: Block? = nil
    
    private(set) var oldFigures = Set<Block>()
}
