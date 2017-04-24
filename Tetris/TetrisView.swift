//  Created by Andy on 23/02/2017.
//  Copyright © 2017 Andy. All rights reserved.

import UIKit

@IBDesignable
class TetrisView: UIView {
    var blockSize: CGFloat {
        if fieldWidth == 0 || fieldHeight == 0 {
            return 0
        } else {
            return floor(0.98 * min(bounds.width / CGFloat(fieldWidth), bounds.height / CGFloat(fieldHeight)) - 2*margin)
        }
    }
    private var margin: CGFloat = 1.0
    
    private var mainColor = UIColor.black
    
    @IBInspectable var gridColor: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
        
    var fieldHeight = 20
    var fieldWidth = 12
    
    var takenPositions: Dictionary<Block, UIColor> = [Block(x:4, y:5): UIColor.red, Block(x:5, y:5): UIColor.red, Block(x:6, y:5): UIColor.red, Block(x:6, y:6): UIColor.red] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private func drawGrid() {
        gridColor.setStroke()
        
        let originX = (bounds.width - CGFloat(fieldWidth) * (blockSize + 2*margin))/2
        let originY = (bounds.height - CGFloat(fieldHeight) * (blockSize + 2*margin))/2
        
        let maxX = originX + CGFloat(fieldWidth) * (blockSize + 2*margin)
        let maxY = originY + CGFloat(fieldHeight) * (blockSize + 2*margin)
        
        for i in 0...fieldWidth {
            let line = UIBezierPath()
            line.lineWidth = margin
            let x = originX + CGFloat(i) * (blockSize + 2*margin)
            line.move(to: CGPoint(x: x, y: originY))
            line.addLine(to: CGPoint(x: x, y: maxY))
            line.stroke()
        }
        for i in 0...fieldHeight {
            let line = UIBezierPath()
            line.lineWidth = margin
            let y = originY + CGFloat(i) * (blockSize + 2*margin)
            line.move(to: CGPoint(x: originX, y: y))
            line.addLine(to: CGPoint(x: maxX, y: y))
            line.stroke()
        }
    }
    
    private func drawBlock(positionX: Int, positionY: Int, color: UIColor) {
        let originX = (bounds.width - CGFloat(fieldWidth) * (blockSize + 2*margin))/2
        let originY = (bounds.height - CGFloat(fieldHeight) * (blockSize + 2*margin))/2
        
        let x = originX + bounds.minX + CGFloat(positionX) * (blockSize + 2*margin) + margin
        let y = originY + bounds.minY + CGFloat(positionY) * (blockSize + 2*margin) + margin
        
        let outer = CGRect(x: x, y: y, width: blockSize, height: blockSize)
        let outerBlock = UIBezierPath(rect: outer)
        outerBlock.lineWidth = 1
        mainColor.setStroke()
        color.setFill()
        outerBlock.stroke()
        outerBlock.fill()
    }
    
    override func draw(_ rect: CGRect) {
        drawGrid()
        
        for (block, color) in takenPositions {
            drawBlock(positionX: block.x, positionY: block.y, color: color)
        }
    }
}
