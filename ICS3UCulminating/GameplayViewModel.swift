import Foundation
import Observation
import SwiftUI

enum GamePhase {
    case placement
    case battle
}

@Observable
class GameplayViewModel {
    
    // MARK: - Stored properties
    
    var playerGrid: Grid
    var aiGrid: Grid
    var phase: GamePhase
    var isPlayerTurn: Bool
    var gameOver: Bool
    var winner: String?
    var statusMessage: String
    
    // Placement state
    var shipsToPlace: [ShipType]
    var currentShipIndex: Int
    var isHorizontal: Bool
    var selectedShipType: ShipType?
    
    // MARK: - Computed properties
    
    var currentShipToPlace: ShipType? {
        if let selected = selectedShipType {
            return selected
        }
        if currentShipIndex < shipsToPlace.count {
            return shipsToPlace[currentShipIndex]
        }
        return nil
    }
    
    // MARK: - Initializer
    
    init() {
        self.playerGrid = Grid()
        self.aiGrid = Grid()
        self.phase = .placement
        self.isPlayerTurn = true
        self.gameOver = false
        self.winner = nil
        self.statusMessage = "Place your Carrier (5 spaces)"
        
        self.shipsToPlace = [.carrier, .battleship, .destroyer, .submarine, .patrolBoat]
        self.currentShipIndex = 0
        self.isHorizontal = true
        self.selectedShipType = nil
        
        setupAIGrid()
    }
    
    // MARK: - Functions
    
    func setupAIGrid() {
        let shipTypes: [ShipType] = [.carrier, .battleship, .destroyer, .submarine, .patrolBoat]
        for type in shipTypes {
            var placed: Bool = false
            while !placed {
                let row: Int = Int.random(in: 0..<10)
                let column: Int = Int.random(in: 0..<10)
                let horizontal: Bool = Bool.random()
                
                var coordinates: [Coordinate] = []
                for i in 0..<type.length {
                    if horizontal {
                        coordinates.append(Coordinate(row: row, column: column + i))
                    } else {
                        coordinates.append(Coordinate(row: row + i, column: column))
                    }
                }
                
                if aiGrid.placeShip(type, at: coordinates) {
                    placed = true
                }
            }
        }
    }
    
    func toggleRotation() {
        isHorizontal.toggle()
    }
    
    func handlePlacementTap(at coordinate: Coordinate) {
        guard phase == .placement else { return }
        
        // 1. If we are currently holding a ship (repositioning or first-time placement)
        if let type = selectedShipType ?? (currentShipIndex < shipsToPlace.count ? shipsToPlace[currentShipIndex] : nil) {
            
            // Calculate potential coordinates
            var coordinates: [Coordinate] = []
            for i in 0..<type.length {
                if isHorizontal {
                    coordinates.append(Coordinate(row: coordinate.row, column: coordinate.column + i))
                } else {
                    coordinates.append(Coordinate(row: coordinate.row + i, column: coordinate.column))
                }
            }
            
            // Try to place it
            if playerGrid.placeShip(type, at: coordinates) {
                if selectedShipType != nil {
                    selectedShipType = nil
                } else {
                    currentShipIndex += 1
                }
                updateStatusAfterPlacement()
                return
            } else {
                // If placement failed, check if we should pick up a DIFFERENT ship instead
                // (Only if we aren't currently "holding" one in selectedShipType)
                if selectedShipType == nil {
                    if let removedType = playerGrid.removeShip(at: coordinate) {
                        selectedShipType = removedType
                        statusMessage = "Repositioning \(removedType.rawValue)"
                        return
                    }
                }
                
                statusMessage = "Invalid placement! Area occupied or out of bounds."
                return
            }
        }
        
        // 2. If all ships are already placed and we aren't "holding" one, we can still pick one up
        if let removedType = playerGrid.removeShip(at: coordinate) {
            selectedShipType = removedType
            statusMessage = "Repositioning \(removedType.rawValue)"
        }
    }
    
    func updateStatusAfterPlacement() {
        if let nextShip = currentShipToPlace {
            statusMessage = "Place your \(nextShip.rawValue) (\(nextShip.length) spaces)"
        } else {
            statusMessage = "All ships placed! Tap 'Ready' to start."
        }
    }
    
    func confirmPlacement() {
        if currentShipIndex >= shipsToPlace.count && selectedShipType == nil {
            withAnimation {
                phase = .battle
                statusMessage = "Battle Start! Fire at the enemy grid."
            }
        }
    }
    
    func playerFired(at coordinate: Coordinate) {
        if phase != .battle || !isPlayerTurn || gameOver { return }
        
        let result: CellState = aiGrid.receiveFire(at: coordinate)
        
        if result == .miss {
            statusMessage = "You missed!"
            isPlayerTurn = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.aiTurn()
            }
        } else if case .hit(let type) = result {
            statusMessage = "You hit their \(type.rawValue)!"
            if aiGrid.allShipsSunk() {
                gameOver = true
                winner = "Player"
                statusMessage = "Game Over: You Win!"
            }
        }
    }
    
    func aiTurn() {
        if gameOver { return }
        
        var validShot: Bool = false
        while !validShot {
            let row: Int = Int.random(in: 0..<10)
            let column: Int = Int.random(in: 0..<10)
            let coordinate = Coordinate(row: row, column: column)
            
            let currentState: CellState = playerGrid.cells[row][column]
            if currentState == .empty || currentState.isShip {
                let result: CellState = playerGrid.receiveFire(at: coordinate)
                validShot = true
                
                if result == .miss {
                    statusMessage = "AI missed!"
                    isPlayerTurn = true
                } else if case .hit(let type) = result {
                    statusMessage = "AI hit your \(type.rawValue)!"
                    if playerGrid.allShipsSunk() {
                        gameOver = true
                        winner = "AI"
                        statusMessage = "Game Over: AI Wins!"
                    } else {
                        isPlayerTurn = true
                    }
                }
            }
        }
    }
}

// MARK: - Extensions

extension CellState {
    var isShip: Bool {
        switch self {
        case .ship:
            return true
        default:
            return false
        }
    }
}
