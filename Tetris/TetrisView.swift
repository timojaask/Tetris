//  Created by Andy on 23/02/2017.
//  Copyright © 2017 Andy. All rights reserved.

import UIKit

@IBDesignable
class TetrisView: UIView {
    var blockSize: CGFloat {
        return fieldWidth != 0 ? floor(0.9 * bounds.width / CGFloat(fieldWidth) - 2*margin) : 0
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
    
    var takenPositions: [(x:Int,y:Int)] = [(4,5), (5,5), (6,5), (6,5)] {
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
    
    private func drawBlock(positionX: Int, positionY: Int) {
        let originX = (bounds.width - CGFloat(fieldWidth) * (blockSize + 2*margin))/2
        let originY = (bounds.height - CGFloat(fieldHeight) * (blockSize + 2*margin))/2
        
        let x = originX + bounds.minX + CGFloat(positionX) * (blockSize + 2*margin) + margin
        let y = originY + bounds.minY + CGFloat(positionY) * (blockSize + 2*margin) + margin
        
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
