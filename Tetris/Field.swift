//  Created by Andy on 04/03/2017.
//  Copyright © 2017 Andy. All rights reserved.

import Foundation

class Field: NSObject {
    override init() {
        super.init()
        self.currentFigure = Figure(blocks: Array<Block>(), field: self)
        spawnFigure()
    }
    
    static let modelUpdateNotification = "dataModelDidUpdateNotification"
    
    var width = 12
    var height = 20
    
    private var stepInterval = 1.0
    
    private var timer: Timer? = nil
    
    func nextStep() {
        if timer != nil {
            timer!.invalidate()
        }
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
    
    func tryToSlide(_ direction: Figure.SlideDirection, steps: Int) {
        var moved = false
        for _ in 1...steps {
            if currentFigure.canSlide(direction, steps: 1) {
                moved = true
                currentFigure.slide(direction, steps: 1)
            }
        }
        
        if moved {
            modelChanged()
        }
    }
    
    func tryToDrop() {
        var moved = false
        
        while currentFigure.canMoveDown() {
            currentFigure.moveDown()
            moved = true
        }
        
        if moved {
            dumpCurrentFigureIntoThePile()
            nextStep()
            modelChanged()
        }
    }
    
    func rotateFigure() {
        if currentFigureCenter == nil {
            return
        }
        
        if currentFigure.canRotate(around: currentFigureCenter!) {
            currentFigure.rotate(around: currentFigureCenter!)
            modelChanged()
        }
    }
    
    func canAdd(_ block: Block) -> Bool {
        return oldFigures.contains(block) || block.x < 0 || block.x >= width || block.y < 0 || block.y >= height
    }
    
    @objc private func moveDown() {
        if !tryToMoveCurrentFigureDown() {
            spawnFigure()
            removeFilledRows()
        }
        nextStep()
    }
    
    private func tryToMoveCurrentFigureDown() -> Bool {
        if !currentFigure.canMoveDown() {
            return false
        }
        
        currentFigure.moveDown()
        
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
        dumpCurrentFigureIntoThePile()
        
        let shapeIndex = arc4random_uniform(Shape.J.rawValue+1)
        let centerX = width / 2 - 1
        let centerY = 1
        if let shape = Shape(rawValue: shapeIndex) {
            switch shape
            {
            case .S:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = Figure(blocks: [currentFigureCenter!,
                                                Block(x: centerX,      y: centerY-1),
                                                Block(x: centerX+1,    y: centerY),
                                                Block(x: centerX+1,    y: centerY+1)],
                                       field: self)
            case .ReverseS:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = Figure(blocks: [currentFigureCenter!,
                                                Block(x: centerX+1,    y: centerY-1),
                                                Block(x: centerX+1,    y: centerY),
                                                Block(x: centerX,      y: centerY+1)],
                                       field: self)
            case .Beam:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = Figure(blocks: [currentFigureCenter!,
                                                Block(x: centerX,      y: centerY-1),
                                                Block(x: centerX,      y: centerY+1),
                                                Block(x: centerX,      y: centerY+2)],
                                       field: self)
            case .Square:
                currentFigureCenter = nil
                currentFigure = Figure(blocks: [Block(x: centerX,      y: centerY),
                                                Block(x: centerX+1,    y: centerY-1),
                                                Block(x: centerX+1,    y: centerY),
                                                Block(x: centerX,      y: centerY-1)],
                                       field: self)
            case .Tee:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = Figure(blocks: [currentFigureCenter!,
                                                Block(x: centerX-1,    y: centerY),
                                                Block(x: centerX,      y: centerY-1),
                                                Block(x: centerX+1,    y: centerY)],
                                       field: self)
            case .L:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = Figure(blocks: [currentFigureCenter!,
                                                Block(x: centerX,      y: centerY-1),
                                                Block(x: centerX,      y: centerY+1),
                                                Block(x: centerX+1,    y: centerY+1)],
                                       field: self)
            case .J:
                currentFigureCenter = Block(x: centerX, y: centerY)
                currentFigure = Figure(blocks: [currentFigureCenter!,
                                                Block(x: centerX,      y: centerY-1),
                                                Block(x: centerX,      y: centerY+1),
                                                Block(x: centerX-1,    y: centerY+1)],
                                       field: self)
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
    
    private func dumpCurrentFigureIntoThePile() {
        for block in currentFigure.blocks {
            oldFigures.insert(block)
        }
    }

    private func modelChanged() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Field.modelUpdateNotification), object: nil)
    }
    
    private(set) var currentFigure: Figure!
    private var currentFigureCenter: Block? = nil
    
    private(set) var oldFigures = Set<Block>()
}
