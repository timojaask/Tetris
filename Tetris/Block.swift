//
//  Block.swift
//  Tetris
//
//  Created by Andy on 03/03/2017.
//  Copyright © 2017 Andy. All rights reserved.
//

class Block : Hashable {
    init(x: Int, y: Int) {
        positionX = x
        positionY = y
    }
    
    var hashValue: Int {
        return positionX.hashValue & positionY.hashValue
    }
    
    static func == (left: Block, right: Block) -> Bool {
        return left.positionX == right.positionX && left.positionY == right.positionY
    }
    
    var positionX: Int
    var positionY: Int
}
