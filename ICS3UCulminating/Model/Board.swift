//
//  Board.swift
//  ICS3UCulminating
//

import Foundation

enum CellState {
    case empty
    case miss
    case hit
}

@Observable
class Board {
    
    // MARK: - Stored properties
    var grid: [[CellState]]
    var ships: [Ship] = []
    let size: Int = 10
    
    // MARK: - Initializer
    init() {
        // Initialize 10x10 grid with empty cells
        var initialGrid: [[CellState]] = []
        for _ in 0..<10 {
            var row: [CellState] = []
            for _ in 0..<10 {
                row.append(.empty)
            }
            initialGrid.append(row)
        }
        self.grid = initialGrid
    }
    
    // MARK: - Functions
    
    // Attempt to place a ship on the board
    func canPlaceShip(type: ShipType, at start: Coordinate, isVertical: Bool) -> Bool {
        let length = type.length
        
        // Check bounds
        if isVertical {
            if start.row + length > size { return false }
        } else {
            if start.column + length > size { return false }
        }
        
        // Check for overlaps
        for i in 0..<length {
            let row = isVertical ? start.row + i : start.row
            let col = isVertical ? start.column : start.column + i
            let coord = Coordinate(row: row, column: col)
            
            if isOccupied(at: coord) {
                return false
            }
        }
        
        return true
    }
    
    // Place a ship
    func placeShip(type: ShipType, at start: Coordinate, isVertical: Bool) {
        if canPlaceShip(type: type, at: start, isVertical: isVertical) == false {
            return
        }
        
        var shipCoordinates: [Coordinate] = []
        for i in 0..<type.length {
            let row = isVertical ? start.row + i : start.row
            let col = isVertical ? start.column : start.column + i
            shipCoordinates.append(Coordinate(row: row, column: col))
        }
        
        let newShip = Ship(type: type, coordinates: shipCoordinates)
        ships.append(newShip)
    }
    
    // Check if a coordinate is occupied by a ship
    func isOccupied(at coordinate: Coordinate) -> Bool {
        for ship in ships {
            for shipCoord in ship.coordinates {
                if shipCoord == coordinate {
                    return true
                }
            }
        }
        return false
    }
    
    // Receive fire at a coordinate
    func receiveFire(at coordinate: Coordinate) -> Bool {
        // Don't allow firing at the same spot twice
        let currentState = grid[coordinate.row][coordinate.column]
        if currentState != .empty {
            return false
        }
        
        var hitAnyShip = false
        for index in 0..<ships.count {
            if ships[index].takeHit(at: coordinate) {
                hitAnyShip = true
                break
            }
        }
        
        if hitAnyShip {
            grid[coordinate.row][coordinate.column] = .hit
        } else {
            grid[coordinate.row][coordinate.column] = .miss
        }
        
        return hitAnyShip
    }
    
    // Check if all ships are sunk
    func allShipsSunk() -> Bool {
        if ships.count == 0 { return false }
        
        for ship in ships {
            if ship.isSunk == false {
                return false
            }
        }
        return true
    }
}
