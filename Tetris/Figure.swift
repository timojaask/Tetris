//  Created by Andy on 08/03/2017.
//  Copyright © 2017 Andy. All rights reserved.

import Foundation

class Figure
{
    init(blocks: Array<Block> = Array<Block>(), field: Field) {
        self.blocks = blocks
        self.field = field
    }
    
    func canSlide(steps: Int) -> Bool {
        for block in blocks {
            if field.canAdd(Block(x: block.x + steps, y: block.y)) {
                return false
            }
        }
        return true
    }
    
    func slide(steps: Int) {
        blocks.forEach { $0.x += steps }
    }
    
    func canMoveDown() -> Bool {
        for block in blocks {
            let newBlock = Block(x: block.x, y: block.y + 1)
            if field.canAdd(newBlock) {
                return false
            }
        }
        return true
    }
    
    func moveDown() {
        blocks.forEach { $0.y += 1 }
    }
    
    func canRotate(around center: Block) -> Bool {
        for block in blocks {            
            if block == center {
                continue
            }
            
            let xDifference = center.x - block.x
            let yDifference = center.y - block.y
            
            let newBlock = Block(x: center.x + yDifference, y: center.y - xDifference)
            
            if field.canAdd(newBlock) {
                return false
            }
        }
        
        return true
    }
    
    func rotate(around center: Block) {
        for block in blocks {
            if block == center {
                continue
            }
            
            let xDifference = center.x - block.x
            let yDifference = center.y - block.y
            
            block.x = center.x + yDifference
            block.y = center.y - xDifference
        }
    }
    
    private(set) var blocks: Array<Block>
    
    private unowned var field: Field
}
