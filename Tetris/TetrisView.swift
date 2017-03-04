//
//  TetrisView.swift
//  Tetris
//
//  Created by Andy on 23/02/2017.
//  Copyright © 2017 Andy. All rights reserved.
//

import UIKit

@IBDesignable
class TetrisView: UIView {
    private var blockSize: CGFloat = 20.0
    private var margin: CGFloat = 2.0

    private var mainColor = UIColor.black

    @IBInspectable var gridColor: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var panOriginX: CGFloat?
    
    private var fieldWidth: Int {
        return Int(bounds.width / (blockSize + margin)) - 1
    }
    
    private var fieldHeight: Int {
        return Int(bounds.height / (blockSize + margin)) - 1
    }
    
    private var currentFigure: [Block] = [Block(x: 4, y: 5), Block(x: 5, y: 5), Block(x: 6, y: 5), Block(x:5, y: 6)]
    
    private var oldFigures: [Block] = []
    
    var timer = Timer()
    
    private func drawGrid() {
        gridColor.setStroke()
        
        let maxX = CGFloat(fieldWidth) * (blockSize + margin)
        let maxY = CGFloat(fieldHeight) * (blockSize + margin)
        
        for i in 0...fieldWidth {
            let line = UIBezierPath()
            let x = CGFloat(i) * (blockSize + margin) - 1
            line.move(to: CGPoint(x: x, y: 0.0))
            line.addLine(to: CGPoint(x: x, y: maxY))
            line.stroke()
        }
        for i in 0...fieldHeight {
            let line = UIBezierPath()
            let y = CGFloat(i) * (blockSize + margin) - 1
            line.move(to: CGPoint(x: 0.0, y: y))
            line.addLine(to: CGPoint(x: maxX, y: y))
            line.stroke()
        }
    }
    
    private func drawBlock(block: Block) {
        let x = bounds.minX + CGFloat(block.positionX) * (blockSize + margin)
        let y = bounds.minY + CGFloat(block.positionY) * (blockSize + margin)
        
        let outer = CGRect(x: x, y: y, width: blockSize, height: blockSize)
        let outerBlock = UIBezierPath(rect: outer)
        outerBlock.lineWidth = 1
        mainColor.setStroke()
        outerBlock.stroke()
    }
    
    override func draw(_ rect: CGRect) {
        drawGrid()
        
        for block in currentFigure + oldFigures {
            drawBlock(block: block)
        }
    }

    
    private func moveCurrentFigure(steps: Int) {
        var stepsToMove = 0
        
        
        for i in 1...abs(steps) {
            let step = i * (steps > 0 ? 1 : -1)
            
            var canMove = true
            
            for block in currentFigure {
                let newPositionX = block.positionX + step
                if newPositionX < 0 || newPositionX >= fieldWidth {
                    canMove = false
                    break
                }
                if oldFigures.contains(where: { return $0.positionX == newPositionX && $0.positionY == block.positionY } ) {
                    canMove = false
                    break
                }
            }
            
            if canMove {
                stepsToMove = step
            }
        }
        
        for block in currentFigure {
            block.positionX += stepsToMove
        }
        setNeedsDisplay()
    }
    
    private func spawnAnotherFigure() {
        oldFigures += currentFigure
        currentFigure = [Block(x: 4, y: 5), Block(x: 5, y: 5), Block(x: 6, y: 5), Block(x:5, y: 6)]
        setNeedsDisplay()
    }
    
    private func tryToMoveCurrentFigureDown() -> Bool {
        for block in currentFigure {
            let newPositionY = block.positionY + 1
            if newPositionY == fieldHeight {
                return false
            }
            
            for oldBlock in oldFigures {
                if oldBlock.positionX == block.positionX && oldBlock.positionY == newPositionY {
                    return false
                }
            }
        }
        
        for block in currentFigure {
            block.positionY += 1
        }
        
        return true
    }
    
    func dropFigure() {
        print ("Drop")
        // Simple code for now
        while tryToMoveCurrentFigureDown() {
        }
        
        setNeedsDisplay()
    }
    
    func moveDown() {
        print("Move")
        
        if tryToMoveCurrentFigureDown() {
            setNeedsDisplay()
        } else {
            spawnAnotherFigure()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 1 {
            return
        }
        
        if let start = touches.first {
            panOriginX = start.location(in: self).x
            print("Began \(panOriginX)")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 1 || panOriginX == nil {
            return
        }
        
        if let current = touches.first {
            let currentX = current.location(in: self).x
            let difference = currentX - panOriginX!
            
            let steps = Int(difference / blockSize / 0.6)
            if steps != 0 {
                print("Moved from \(panOriginX) to \(currentX)")
                panOriginX = currentX
                moveCurrentFigure(steps: steps)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        panOriginX = nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        panOriginX = nil
    }
}
