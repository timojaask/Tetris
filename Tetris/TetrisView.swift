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
        
        for block in currentFigure {
            drawBlock(block: block)
        }
    }
    
    func moveCurrentFigure(steps: Int) {
        for block in currentFigure {
            let newPosition = block.positionX + steps
            if newPosition < 0 || newPosition >= fieldWidth {
                return
            }
        }
        
        for block in currentFigure {
            block.positionX += steps
        }
        setNeedsDisplay()
    }
    
    func dropFigure() {
        print ("Drop")
        // Simple code for now
        var lowestPoint = 0
        for block in currentFigure {
            lowestPoint = max(lowestPoint, block.positionY)
        }
        let distance = fieldHeight - lowestPoint - 1
        for block in currentFigure {
            block.positionY += distance
        }
        setNeedsDisplay()
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
