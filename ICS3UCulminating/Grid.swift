import Foundation
import Observation

@Observable
class Grid {
    
    // MARK: - Stored properties
    
    var cells: [[CellState]]
    var ships: [Ship]
    
    // MARK: - Initializer
    
    init() {
        var initialCells: [[CellState]] = []
        for _ in 0..<10 {
            var row: [CellState] = []
            for _ in 0..<10 {
                row.append(.empty)
            }
            initialCells.append(row)
        }
        self.cells = initialCells
        self.ships = []
    }
    
    // MARK: - Functions
    
    func placeShip(_ type: ShipType, at coordinates: [Coordinate]) -> Bool {
        // Check if coordinates are valid and unoccupied
        for coordinate in coordinates {
            if coordinate.row < 0 || coordinate.row >= 10 || coordinate.column < 0 || coordinate.column >= 10 {
                return false
            }
            if cells[coordinate.row][coordinate.column] != .empty {
                return false
            }
        }
        
        // Place ship
        let newShip = Ship(type: type, coordinates: coordinates)
        ships.append(newShip)
        
        for coordinate in coordinates {
            cells[coordinate.row][coordinate.column] = .ship(type)
        }
        
        return true
    }
    
    func removeShip(at coordinate: Coordinate) -> ShipType? {
        let state = cells[coordinate.row][coordinate.column]
        if case .ship(let type) = state {
            // Find the ship in our array
            var targetIndex: Int = -1
            for index in 0..<ships.count {
                if ships[index].type == type {
                    targetIndex = index
                }
            }
            
            if targetIndex != -1 {
                let ship = ships.remove(at: targetIndex)
                // Clear cells
                for coord in ship.coordinates {
                    cells[coord.row][coord.column] = .empty
                }
                return type
            }
        }
        return nil
    }
    
    func receiveFire(at coordinate: Coordinate) -> CellState {
        let currentState = cells[coordinate.row][coordinate.column]
        
        switch currentState {
        case .empty:
            cells[coordinate.row][coordinate.column] = .miss
            return .miss
        case .ship(let type):
            cells[coordinate.row][coordinate.column] = .hit(type)
            
            // Update ship hit status
            for index in 0..<ships.count {
                if ships[index].type == type {
                    ships[index].registerHit(at: coordinate)
                }
            }
            return .hit(type)
        case .hit, .miss:
            return currentState // Already fired here
        }
    }
    
    func allShipsSunk() -> Bool {
        if ships.count == 0 {
            return false
        }
        
        for ship in ships {
            if ship.isSunk == false {
                return false
            }
        }
        return true
    }
}
