//
//  Field.swift
//  Tetris
//
//  Created by Andy on 04/03/2017.
//  Copyright © 2017 Andy. All rights reserved.
//

import Foundation

class Field {
    init() {
        spawnFigure()
    }

    static let modelUpdateNotification = "dataModelDidUpdateNotification"
    
    var width = 12
    var height = 20
    
    func spawnFigure() {
        oldFigures += currentFigure
        currentFigure = [Block(x: 4, y: 5), Block(x: 5, y: 5), Block(x: 6, y: 5), Block(x:5, y: 6)]
        modelChanged()
    }
    
    func tryToSlide(steps: Int) {
        var stepsToMove = 0
        
        for i in 1...abs(steps) {
            let step = i * (steps > 0 ? 1 : -1)
            
            var canMove = true
            
            for block in currentFigure {
                let newPositionX = block.positionX + step
                if newPositionX < 0 || newPositionX >= width {
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
        
        if stepsToMove != 0 {
            for block in currentFigure {
                block.positionX += stepsToMove
            }
            modelChanged()
        }        
    }
    
    func tryToDrop() {
        // Simple code for now
        while tryToMoveCurrentFigureDown() {
        }
    }
    
    func moveDown() {
        if !tryToMoveCurrentFigureDown() {
            spawnFigure()
        }
    }
    
    private func tryToMoveCurrentFigureDown() -> Bool {
        for block in currentFigure {
            let newPositionY = block.positionY + 1
            if newPositionY == height {
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
        
        modelChanged()
        
        return true
    }
    
    private func modelChanged() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Field.modelUpdateNotification), object: nil)
    }
    
    private(set) var currentFigure: [Block] = []
    
    private(set) var oldFigures: [Block] = []
}
