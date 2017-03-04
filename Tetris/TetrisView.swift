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
    private(set) var blockSize: CGFloat = 20.0
    private var margin: CGFloat = 2.0

    private var mainColor = UIColor.black
    
    @IBInspectable var gridColor: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
        
    var fieldHeight = 0
    var fieldWidth = 0
    
    var takenPositions: [(x:Int,y:Int)] = [(x:Int,y:Int)]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
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
    
    private func drawBlock(positionX: Int, positionY: Int) {
        let x = bounds.minX + CGFloat(positionX) * (blockSize + margin)
        let y = bounds.minY + CGFloat(positionY) * (blockSize + margin)
        
        let outer = CGRect(x: x, y: y, width: blockSize, height: blockSize)
        let outerBlock = UIBezierPath(rect: outer)
        outerBlock.lineWidth = 1
        mainColor.setStroke()
        outerBlock.stroke()
    }
    
    override func draw(_ rect: CGRect) {
        drawGrid()
        
        for position in takenPositions {
            drawBlock(positionX: position.x, positionY: position.y)
        }
    }
}
