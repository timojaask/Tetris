//  Created by Andy on 23/02/2017.
//  Copyright © 2017 Andy. All rights reserved.

import UIKit

func getBorderColor(shapeColor: UIColor) -> UIColor {
    var hue = CGFloat()
    var saturation = CGFloat()
    var brightness = CGFloat()
    var alpha = CGFloat()

    shapeColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    brightness *= 0.95

    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
}

@IBDesignable
class NextShapeView: UIView {
    var shape: Figure.Shape? = nil {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var gridColor: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }

    let fieldWidth = 4
    let fieldHeight = 4
    private var margin: CGFloat = 1.0

    override func draw(_ rect: CGRect) {
        drawGrid()
        guard let shape = self.shape, let blocks = blocksForShape(shape: shape, centerX: 1, centerY: 1) else { return }
        let color = shapeColor(shape)
        let borderColor = getBorderColor(shapeColor: color)
        blocks.forEach { block in
            drawBlock(positionX: block.x, positionY: block.y, color: color, borderColor: borderColor)
        }

    }

    private func drawGrid() {
        gridColor.setStroke()

        var blockSize: CGFloat {
            if fieldWidth == 0 || fieldHeight == 0 {
                return 0
            } else {
                return floor(0.98 * min(bounds.width / CGFloat(fieldWidth), bounds.height / CGFloat(fieldHeight)) - 2*margin)
            }
        }

        let originX = (bounds.width - CGFloat(fieldWidth) * (blockSize + 2*margin))/2
        let originY = (bounds.height - CGFloat(fieldHeight) * (blockSize + 2*margin))/2

        let maxX = originX + CGFloat(fieldWidth) * (blockSize + 2*margin)
        let maxY = originY + CGFloat(fieldHeight) * (blockSize + 2*margin)

        for i in 0...fieldWidth {
            let line = UIBezierPath()
            line.lineWidth = margin*2
            let x = originX + CGFloat(i) * (blockSize + 2*margin)
            line.move(to: CGPoint(x: x, y: originY))
            line.addLine(to: CGPoint(x: x, y: maxY))
            line.stroke()
        }
        for i in 0...fieldHeight {
            let line = UIBezierPath()
            line.lineWidth = margin*2
            let y = originY + CGFloat(i) * (blockSize + 2*margin)
            line.move(to: CGPoint(x: originX, y: y))
            line.addLine(to: CGPoint(x: maxX, y: y))
            line.stroke()
        }
    }

    private func drawBlock(positionX: Int, positionY: Int, color: UIColor, borderColor: UIColor) {

        var blockSize: CGFloat {
            if fieldWidth == 0 || fieldHeight == 0 {
                return 0
            } else {
                return floor(0.98 * min(bounds.width / CGFloat(fieldWidth), bounds.height / CGFloat(fieldHeight)) - 2*margin)
            }
        }

        let originX = (bounds.width - CGFloat(fieldWidth) * (blockSize + 2*margin))/2
        let originY = (bounds.height - CGFloat(fieldHeight) * (blockSize + 2*margin))/2

        let x = originX + bounds.minX + CGFloat(positionX) * (blockSize + 2*margin)
        let y = originY + bounds.minY + CGFloat(positionY) * (blockSize + 2*margin)

        let outer = CGRect(x: x, y: y, width: blockSize + margin*2, height: blockSize + margin*2)
        let outerBlock = UIBezierPath(rect: outer)
        color.setFill()
        outerBlock.fill()

        borderColor.setStroke()

        let b = UIBezierPath()
        b.move(to: CGPoint(x: outer.minX, y: outer.maxY-0.5))
        b.addLine(to: CGPoint(x: outer.maxX - 0.5, y: outer.maxY - 0.5))
        b.addLine(to: CGPoint(x: outer.maxX - 0.5, y: outer.minY))
        b.stroke()
    }
}

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

    private var borderColors = Dictionary<UIColor, UIColor>()
    
    private func drawGrid() {
        gridColor.setStroke()
        
        let originX = (bounds.width - CGFloat(fieldWidth) * (blockSize + 2*margin))/2
        let originY = (bounds.height - CGFloat(fieldHeight) * (blockSize + 2*margin))/2
        
        let maxX = originX + CGFloat(fieldWidth) * (blockSize + 2*margin)
        let maxY = originY + CGFloat(fieldHeight) * (blockSize + 2*margin)
        
        for i in 0...fieldWidth {
            let line = UIBezierPath()
            line.lineWidth = margin*2
            let x = originX + CGFloat(i) * (blockSize + 2*margin)
            line.move(to: CGPoint(x: x, y: originY))
            line.addLine(to: CGPoint(x: x, y: maxY))
            line.stroke()
        }
        for i in 0...fieldHeight {
            let line = UIBezierPath()
            line.lineWidth = margin*2
            let y = originY + CGFloat(i) * (blockSize + 2*margin)
            line.move(to: CGPoint(x: originX, y: y))
            line.addLine(to: CGPoint(x: maxX, y: y))
            line.stroke()
        }
    }
    
    private func drawBlock(positionX: Int, positionY: Int, color: UIColor) {
        let originX = (bounds.width - CGFloat(fieldWidth) * (blockSize + 2*margin))/2
        let originY = (bounds.height - CGFloat(fieldHeight) * (blockSize + 2*margin))/2
        
        let x = originX + bounds.minX + CGFloat(positionX) * (blockSize + 2*margin)
        let y = originY + bounds.minY + CGFloat(positionY) * (blockSize + 2*margin)
        
        let outer = CGRect(x: x, y: y, width: blockSize + margin*2, height: blockSize + margin*2)
        let outerBlock = UIBezierPath(rect: outer)
        color.setFill()
        outerBlock.fill()

        var borderColor = borderColors[color]
        if borderColor == nil {
            borderColor = getBorderColor(shapeColor: color)
            borderColors[color] = borderColor
        }

        borderColor!.setStroke()

        let b = UIBezierPath()
        b.move(to: CGPoint(x: outer.minX, y: outer.maxY-0.5))
        b.addLine(to: CGPoint(x: outer.maxX - 0.5, y: outer.maxY - 0.5))
        b.addLine(to: CGPoint(x: outer.maxX - 0.5, y: outer.minY))
        b.stroke()
    }

    override func draw(_ rect: CGRect) {
        drawGrid()
        
        for (block, color) in takenPositions {
            drawBlock(positionX: block.x, positionY: block.y, color: color)
        }
    }
}
